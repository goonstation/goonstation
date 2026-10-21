/**
 * @file
 * @copyright 2022
 * @author Amylizzle (https://github.com/amylizzle)
 * @author Sovexe  (https://github.com/Sovexe)
 * @license MIT
 */

import {
  Box,
  Button,
  Chart,
  Dimmer,
  Icon,
  Input,
  Knob,
  LabeledList,
  RoundGauge,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { formatPower, formatPressure, formatSiUnit } from '../../format';
import { Window } from '../../layouts';
import type {
  TurbineBladeData,
  TurbineControlData,
  TurbineHistorySample,
} from './type';

type HistoryMetric =
  | 'power'
  | 'rpm'
  | 'temperature'
  | 'pressure'
  | 'outletTemperature'
  | 'outletPressure';
type TurbineStatus =
  | 'disconnected'
  | 'ruined'
  | 'overspeed'
  | 'overtemp'
  | 'stalled'
  | 'undertemp'
  | 'damaged'
  | 'idle'
  | 'nominal';

const getTurbineStatus = (
  data: Pick<
    TurbineControlData,
    | 'connected'
    | 'ruined'
    | 'overspeed'
    | 'overtemp'
    | 'undertemp'
    | 'stalling'
    | 'rpm'
    | 'blade'
    | 'stator'
  >,
): TurbineStatus => {
  if (!data.connected) {
    return 'disconnected';
  }
  if (data.ruined || !data.blade?.installed || !data.stator?.installed) {
    return 'ruined';
  }
  if (data.overspeed) {
    return 'overspeed';
  }
  if (data.overtemp) {
    return 'overtemp';
  }
  if (data.stalling) {
    return 'stalled';
  }
  if (data.undertemp) {
    return 'undertemp';
  }
  if (data.blade?.installed && data.blade.healthPercent <= 50) {
    return 'damaged';
  }
  if (!data.rpm) {
    return 'idle';
  }
  return 'nominal';
};

const loadToExponent = (load: number, minLoad: number, maxLoad: number) =>
  Math.min(
    Math.max(Math.log10(Math.max(load, minLoad)), Math.log10(minLoad)),
    Math.log10(maxLoad),
  );

const exponentToLoad = (exponent: number, minLoad: number, maxLoad: number) =>
  Math.min(Math.max(10 ** exponent, minLoad), maxLoad);

const formatLoad = (load: number) => `${formatSiUnit(load, 0, 'J')}/revolution`;

const formatTemperature = (temperature: number) =>
  `${Math.round(temperature)} K`;

const formatRPM = (rpm: number) => `${Math.round(rpm)} RPM`;

const HISTORY_CHART_STROKE_COLOR = 'rgba(203, 135, 66, 1)';
const HISTORY_CHART_FILL_COLOR = 'rgba(241, 183, 125, 0.25)';

const chartData = (values: number[]) => {
  if (!values.length) {
    return [[0, 0]];
  }
  return values.map((value, index) => [index, value]);
};

const chartMaximum = (values: number[]) => Math.max(1, ...values);

const historyValues = (
  history: TurbineHistorySample[],
  metric: HistoryMetric,
) =>
  history.map((sample) => {
    const value = sample[metric];
    return Number.isFinite(value) ? value : 0;
  });

const buildHistoryChart = (
  history: TurbineHistorySample[],
  metric: HistoryMetric,
) => {
  const values = historyValues(history, metric);
  return {
    data: chartData(values),
    max: chartMaximum(values),
  };
};

const statusLabel: Record<TurbineStatus, string> = {
  disconnected: 'NO TURBINE LINK',
  ruined: 'COMPONENT FAULT',
  overspeed: 'OVERSPEED',
  overtemp: 'THERMAL WARNING',
  stalled: 'STALLED',
  undertemp: 'UNDER-TEMPERATURE',
  damaged: 'BLADE DAMAGED',
  idle: 'IDLE',
  nominal: 'NOMINAL',
};

const statusColor: Record<TurbineStatus, string> = {
  disconnected: 'average',
  ruined: 'bad',
  overspeed: 'bad',
  overtemp: 'bad',
  stalled: 'bad',
  undertemp: 'average',
  damaged: 'bad',
  idle: 'average',
  nominal: 'good',
};

const bladeStatus = (blade: TurbineBladeData | null) => {
  if (!blade?.installed) {
    return 'Missing';
  }
  if (blade.healthPercent <= 25) {
    return 'Critical';
  }
  if (blade.healthPercent <= 50) {
    return 'Worn';
  }
  return 'Good';
};

const bladeStatusColor = (blade: TurbineBladeData | null) => {
  const status = bladeStatus(blade);
  if (status === 'Good') {
    return 'good';
  }
  if (status === 'Worn') {
    return 'average';
  }
  return 'bad';
};

type LoadAdjustmentControlsProps = {
  load: number;
  onCommit: (value: string) => void;
  onAdjust: (factor: number) => void;
};

const LoadAdjustmentControls = ({
  load,
  onCommit,
  onAdjust,
}: LoadAdjustmentControlsProps) => (
  <Stack vertical>
    <Stack.Item>
      <Stack align="center">
        <Stack.Item>
          <Input value={`${load / 1000}`} monospace onBlur={onCommit} />
        </Stack.Item>
        <Stack.Item>
          <Box>kJ/rev</Box>
        </Stack.Item>
      </Stack>
    </Stack.Item>
    <Stack.Item>
      <Stack>
        <Stack.Item>
          <Button onClick={() => onAdjust(0.9)}>-10%</Button>
        </Stack.Item>
        <Stack.Item>
          <Button onClick={() => onAdjust(0.99)}>-1%</Button>
        </Stack.Item>
        <Stack.Item>
          <Button onClick={() => onAdjust(1.01)}>+1%</Button>
        </Stack.Item>
        <Stack.Item>
          <Button onClick={() => onAdjust(1.1)}>+10%</Button>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  </Stack>
);

type HistoryPanel = {
  label: string;
  value: string;
  chart: {
    data: number[][];
    max: number;
  };
};

const HistoryGrid = ({
  panels,
  hasHistory,
}: {
  panels: HistoryPanel[];
  hasHistory: boolean;
}) => (
  <Stack vertical>
    <Stack.Item>
      <Stack wrap="wrap" justify="space-around">
        {panels.map((panel) => (
          <Stack.Item key={panel.label} grow minWidth={20} maxWidth={25}>
            <Stack vertical>
              <Stack.Item>
                <Box color="label">
                  {panel.label}: {panel.value}
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Chart.Line
                  height="4em"
                  data={panel.chart.data}
                  rangeX={[0, Math.max(panel.chart.data.length - 1, 1)]}
                  rangeY={[0, panel.chart.max]}
                  strokeColor={HISTORY_CHART_STROKE_COLOR}
                  fillColor={HISTORY_CHART_FILL_COLOR}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        ))}
      </Stack>
    </Stack.Item>
    {!hasHistory && (
      <Stack.Item>
        <Box color="label">No samples yet.</Box>
      </Stack.Item>
    )}
  </Stack>
);

const turbineWindowProps = {
  width: 520,
  height: 770,
  theme: 'retro-dark',
  title: 'Gas Turbine Operator Console',
};

export const TurbineControl = () => {
  const { act, data } = useBackend<TurbineControlData>();

  if (!data.connected) {
    return (
      <Window {...turbineWindowProps}>
        <Window.Content>
          <Dimmer>NO TURBINE LINK</Dimmer>
        </Window.Content>
      </Window>
    );
  }

  const status = getTurbineStatus(data);
  const historyPanels = [
    {
      label: 'Output',
      value: formatPower(data.power),
      chart: buildHistoryChart(data.history, 'power'),
    },
    {
      label: 'RPM',
      value: `${Math.round(data.rpm)} RPM`,
      chart: buildHistoryChart(data.history, 'rpm'),
    },
    {
      label: 'Inlet temperature',
      value: formatTemperature(data.inletTemperature),
      chart: buildHistoryChart(data.history, 'temperature'),
    },
    {
      label: 'Inlet pressure',
      value: formatPressure(data.inletPressure),
      chart: buildHistoryChart(data.history, 'pressure'),
    },
    {
      label: 'Outlet temperature',
      value: formatTemperature(data.outletTemperature),
      chart: buildHistoryChart(data.history, 'outletTemperature'),
    },
    {
      label: 'Outlet pressure',
      value: formatPressure(data.outletPressure),
      chart: buildHistoryChart(data.history, 'outletPressure'),
    },
  ];
  const rpmGaugeMax = Math.max(data.overspeedRPM * 1.5, data.rpm * 1.1, 1);
  const temperatureGaugeMax = Math.max(
    data.overtempLimit * 1.1,
    data.inletTemperature * 1.1,
    1,
  );
  const loadExponent = loadToExponent(
    data.load,
    data.statorLoadMin,
    data.statorLoadMax,
  );
  const adjustLoad = (factor: number) =>
    act('loadChange', { newVal: data.load * factor });
  const commitLoad = (value: string) => {
    const load = Number(value);
    if (Number.isFinite(load)) {
      act('loadChange', { newVal: load * 1000 });
    }
  };
  return (
    <Window {...turbineWindowProps}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack>
                <Stack.Item>
                  <Box color={statusColor[status]} textAlign="center">
                    <Icon name="cog" size={3} spin={!!data.rpm} />
                  </Box>
                </Stack.Item>
                <Stack.Item grow>
                  <Box color="label">TURBINE STATUS</Box>
                  <Box color={statusColor[status]} bold fontSize={1.5}>
                    {statusLabel[status]}
                  </Box>
                </Stack.Item>
                <Stack.Item textAlign="right">
                  <Box color="label">POWER OUTPUT</Box>
                  <Box bold fontSize={1.5}>
                    {formatPower(data.power)}
                  </Box>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Live Instruments">
              <Stack justify="space-around" align="center" wrap="wrap">
                <Stack.Item>
                  <Box textAlign="center">RPM</Box>
                  <RoundGauge
                    size={4}
                    value={Math.min(data.rpm, rpmGaugeMax)}
                    minValue={0}
                    maxValue={rpmGaugeMax}
                    alertAfter={data.overspeedRPM}
                    format={formatRPM}
                    ranges={{
                      average: [0, data.optimalRPM * 0.75],
                      good: [data.optimalRPM * 0.75, data.overspeedRPM],
                      bad: [data.overspeedRPM, rpmGaugeMax],
                    }}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Box textAlign="center">TEMPERATURE</Box>
                  <RoundGauge
                    size={4}
                    value={Math.min(data.inletTemperature, temperatureGaugeMax)}
                    minValue={0}
                    maxValue={temperatureGaugeMax}
                    alertAfter={data.overtempWarning}
                    format={formatTemperature}
                    ranges={{
                      blue: [0, data.minimumTemperature],
                      good: [data.minimumTemperature, data.overtempWarning],
                      average: [data.overtempWarning, data.overtempLimit],
                      bad: [data.overtempLimit, temperatureGaugeMax],
                    }}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Tuning Controls">
              <Stack vertical>
                <Stack.Item>
                  <Stack align="center">
                    <Stack.Item>
                      <Box>Stator Load</Box>
                      <Box color="label">{formatLoad(data.load)}</Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Knob
                        animated
                        size={2}
                        value={loadExponent}
                        minValue={Math.log10(data.statorLoadMin)}
                        maxValue={Math.log10(data.statorLoadMax)}
                        step={0.05}
                        format={(value) =>
                          formatLoad(
                            exponentToLoad(
                              value,
                              data.statorLoadMin,
                              data.statorLoadMax,
                            ),
                          )
                        }
                        onChange={(_event, value) =>
                          act('loadChange', {
                            newVal: exponentToLoad(
                              value,
                              data.statorLoadMin,
                              data.statorLoadMax,
                            ),
                          })
                        }
                      />
                    </Stack.Item>
                    <Stack.Item grow>
                      <LoadAdjustmentControls
                        load={data.load}
                        onCommit={commitLoad}
                        onAdjust={adjustLoad}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item>
                  <Stack align="center">
                    <Stack.Item>
                      <Box>Flow Rate</Box>
                      <Box color="label">{data.volume} L/s</Box>
                    </Stack.Item>
                    <Stack.Item grow>
                      <Slider
                        value={data.volume}
                        minValue={data.flowRateMin}
                        maxValue={data.volumeMax}
                        step={1}
                        unit="L/s"
                        onChange={(_event, value) =>
                          act('volChange', { newVal: value })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="History">
              <HistoryGrid
                panels={historyPanels}
                hasHistory={!!data.history.length}
              />
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Component Diagnostics">
              <LabeledList>
                <LabeledList.Item label="Blade">
                  <Box color={bladeStatusColor(data.blade)}>
                    {bladeStatus(data.blade)}
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="Stator">
                  {data.stator?.installed ? (
                    <Box color="good">Installed</Box>
                  ) : (
                    <Box color="bad">MISSING</Box>
                  )}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
