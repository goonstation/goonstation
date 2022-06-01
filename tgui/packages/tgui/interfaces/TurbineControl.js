import { useBackend } from '../backend';
import { Chart, LabeledList, Stack, Table } from '../components';
import { formatPower } from '../format';
import { Window } from '../layouts';

export const TurbineControl = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    rpm,
    load,
    power,
    history,
  } = data;
  const rpmHistory = history.map((v) => v[0]);
  const rpmHistoryData = rpmHistory.map((v, i) => [i, v]);

  const loadHistory = history.map((v) => v[1]);
  const loadHistoryData = loadHistory.map((v, i) => [i, v]);

  const powerHistory = history.map((v) => v[2]);
  const powerHistoryData = powerHistory.map((v, i) => [i, v]);

  const max = Math.max(...powerHistory, ...loadHistory);

  return (
    <Window>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="50%">
            <LabeledList>
              <LabeledList.Item label="Turbine Output">{formatPower(power)}</LabeledList.Item>
            </LabeledList>
            <Chart.Line
              mt="5px"
              height="5em"
              data={powerHistoryData}
              rangeX={[0, powerHistoryData.length - 1]}
              rangeY={[0, max]}
              strokeColor="rgba(1, 184, 170, 1)"
              fillColor="rgba(1, 184, 170, 0.25)"
            />
          </Stack.Item>
          <Stack.Item width="50%">
            <LabeledList>
              <LabeledList.Item label="Turbine Speed">{rpm} RPM</LabeledList.Item>
            </LabeledList>
            <Chart.Line
              mt="5px"
              height="5em"
              data={rpmHistoryData}
              rangeX={[0, rpmHistoryData.length - 1]}
              rangeY={[0, max]}
              strokeColor="rgba(1, 184, 170, 1)"
              fillColor="rgba(1, 184, 170, 0.25)"
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
