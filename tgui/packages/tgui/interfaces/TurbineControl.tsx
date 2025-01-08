/**
 * @file
 * @copyright 2022
 * @author Amylizzle https://github.com/amylizzle
 * @license MIT
 */

import { Chart, LabeledList, NumberInput, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { formatPower } from '../format';
import { Window } from '../layouts';

interface TurbineControlData {
  rpm;
  load;
  power;
  volume;
  volume_max;
  history;
  overspeed;
  overtemp;
  undertemp;
}

export const TurbineControl = () => {
  const { act, data } = useBackend<TurbineControlData>();
  const {
    rpm,
    load,
    power,
    volume,
    volume_max,
    history,
    overspeed,
    overtemp,
    undertemp,
  } = data;
  const rpmHistory = history.map((v) => v[0]);
  const rpmHistoryData = rpmHistory.map((v, i) => [i, v]);

  const loadHistory = history.map((v) => v[1]);
  const loadHistoryData = loadHistory.map((v, i) => [i, v]);

  const powerHistory = history.map((v) => v[2]);
  const powerHistoryData = powerHistory.map((v, i) => [i, v]);

  const powermax = Math.max(...powerHistory);
  const rpmmax = Math.max(...rpmHistory);
  const loadmax = Math.max(...loadHistory);

  return (
    <Window width={375} height={400}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="Turbine Output">
                {formatPower(power)}
              </LabeledList.Item>
            </LabeledList>
            <Chart.Line
              mt="5px"
              height="5em"
              data={powerHistoryData}
              rangeX={[0, powerHistoryData.length - 1]}
              rangeY={[0, powermax]}
              strokeColor="rgba(1, 184, 170, 1)"
              fillColor="rgba(1, 184, 170, 0.25)"
            />
          </Stack.Item>
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="Turbine Speed">
                {rpm} RPM
              </LabeledList.Item>
              {overspeed ? (
                <LabeledList.Item label="ALERT" color="#FF0000">
                  OVERSPEED
                </LabeledList.Item>
              ) : (
                ''
              )}
              {overtemp ? (
                <LabeledList.Item label="ALERT" color="#FF0000">
                  OVER TEMPERATURE
                </LabeledList.Item>
              ) : (
                ''
              )}
              {undertemp ? (
                <LabeledList.Item label="ALERT" color="#FF0000">
                  UNDER TEMPERATURE
                </LabeledList.Item>
              ) : (
                ''
              )}
            </LabeledList>
            <Chart.Line
              mt="5px"
              height="5em"
              data={rpmHistoryData}
              rangeX={[0, rpmHistoryData.length - 1]}
              rangeY={[0, rpmmax]}
              strokeColor="rgba(1, 184, 170, 1)"
              fillColor="rgba(1, 184, 170, 0.25)"
            />
          </Stack.Item>
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="Turbine Load">
                {load / 1000} kJ/Revolution
              </LabeledList.Item>
            </LabeledList>
            <Chart.Line
              mt="5px"
              height="5em"
              data={loadHistoryData}
              rangeX={[0, loadHistoryData.length - 1]}
              rangeY={[0, loadmax]}
              strokeColor="rgba(1, 184, 170, 1)"
              fillColor="rgba(1, 184, 170, 0.25)"
            />
          </Stack.Item>
          <Stack.Item>
            Stator Load:
            <NumberInput
              minValue={1}
              maxValue={10e30 / 1000}
              value={load / 1000}
              format={(value) => value + ' kJ/Revolution'}
              step={1}
              onChange={(value) => act('loadChange', { newVal: value * 1000 })}
            />
          </Stack.Item>
          <Stack.Item>
            Flow Rate:
            <NumberInput
              minValue={1}
              maxValue={volume_max}
              value={volume}
              format={(value) => value + ' L/s'}
              step={1}
              onChange={(value) => act('volChange', { newVal: value })}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
