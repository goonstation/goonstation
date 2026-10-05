/**
 * @file
 * @copyright 2026
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */
import { useBackend } from 'tgui/backend';
import { HealthStat } from 'tgui/components/goonstation/HealthStat';
import { COLORS } from 'tgui/constants';
import { Box, Chart, Section, Stack } from 'tgui-core/components';

import { getStatsMax, processStatsData } from '../graphUtils';
import { DisplayOccupiedProps, HealthGraphData } from './type';

type DamageTypes = 'oxy' | 'toxin' | 'burn' | 'brute';

type ProcessedHealthStats = Record<DamageTypes, number[][]>;

export const DisplayVitalsGraph = () => {
  const { data } = useBackend<HealthGraphData>();
  const processedData = processStatsData(
    data.patient_data,
  ) as ProcessedHealthStats;
  const oxy = data.occupied ? Math.floor(data.oxygen).toString() : '--';
  const oxy_data = data.occupied && processedData ? processedData['oxy'] : [];
  const toxin = data.occupied ? Math.floor(data.toxin).toString() : '--';
  const toxin_data =
    data.occupied && processedData ? processedData['toxin'] : [];
  const burn = data.occupied ? Math.floor(data.burn).toString() : '--';
  const burn_data = data.occupied && processedData ? processedData['burn'] : [];
  const brute = data.occupied ? Math.floor(data.brute).toString() : '--';
  const brute_data =
    data.occupied && processedData ? processedData['brute'] : [];

  return (
    <Section title="Vitals">
      <Stack textAlign="center">
        <HealthGraph
          title="Suffocation"
          value={oxy}
          metric_data={oxy_data}
          metric="oxy"
        />
        <HealthGraph
          title="Toxin"
          value={toxin}
          metric_data={toxin_data}
          metric="toxin"
        />
        <HealthGraph
          title="Burn"
          value={burn}
          metric_data={burn_data}
          metric="burn"
        />
        <HealthGraph
          title="Brute"
          value={brute}
          metric_data={brute_data}
          metric="brute"
        />
      </Stack>
    </Section>
  );
};

type DisplayVitalsProps = DisplayOccupiedProps & {
  oxygen: number;
  toxin: number;
  burn: number;
  brute: number;
};

export const DisplayVitals = (props: DisplayVitalsProps) => {
  const { occupied, oxygen, toxin, burn, brute } = props;
  const oxy_value = occupied ? Math.floor(oxygen).toString() : '--';
  const toxin_value = occupied ? Math.floor(toxin).toString() : '--';
  const burn_value = occupied ? Math.floor(burn).toString() : '--';
  const brute_value = occupied ? Math.floor(brute).toString() : '--';
  return (
    <Section title="Vitals">
      <Stack textAlign="center">
        <HealthNumber title="Suffocation" value={oxy_value} metric="oxy" />
        <HealthNumber title="Toxin" value={toxin_value} metric="toxin" />
        <HealthNumber title="Burn" value={burn_value} metric="burn" />
        <HealthNumber title="Brute" value={brute_value} metric="brute" />
      </Stack>
    </Section>
  );
};

interface HealthNumberProps {
  metric: DamageTypes;
  title: string;
  value: string | number;
}

const HealthNumber = (props: HealthNumberProps) => {
  const { metric, value, title } = props;
  return (
    <Stack.Item width={25}>
      <HealthStat type={metric}>
        {title}
        <br />
        <Box fontSize={3}>{value}</Box>
      </HealthStat>
    </Stack.Item>
  );
};

interface HealthGraphProps {
  metric: DamageTypes;
  title: string;
  value: string;
  metric_data: number[][];
}

const HealthGraph = (props: HealthGraphProps) => {
  const { metric, value, metric_data, title } = props;
  return (
    <Stack.Item width={25}>
      <HealthStat type={metric}>
        {title}
        <br />
        <Box fontSize={4}>{value}</Box>
        <Box>
          {metric_data && (
            <Chart.Line
              mt="5px"
              height="5em"
              data={metric_data}
              rangeX={[0, metric_data.length - 1]}
              rangeY={[0, Math.max(100, getStatsMax(metric_data))]}
              strokeColor={COLORS.damageType[metric]}
              fillColor={COLORS.damageTypeFill[metric]}
            />
          )}
        </Box>
      </HealthStat>
    </Stack.Item>
  );
};
