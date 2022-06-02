import { useBackend } from '../backend';
import { Chart, LabeledList, Stack, Slider, Box } from '../components';
import { formatPower } from '../format';
import { Window } from '../layouts';

export const TurbineControl = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    rpm,
    load,
    power,
    volume,
    history,
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
    <Window>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="Turbine Output">{formatPower(power)}</LabeledList.Item>
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
              <LabeledList.Item label="Turbine Speed">{rpm} RPM</LabeledList.Item>
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
              <LabeledList.Item label="Turbine Load">{load} Watts/RPM</LabeledList.Item>
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
            <Box>
              <Slider
                minValue={1}
                maxValue={load*2}
                value={load}
                format={value => value + " Watts/RPM"}
                onChange={(e, value) => act("loadChange", { newVal: value })} />
              <Slider
                minValue={1}
                maxValue={volume*2}
                value={volume}
                format={value => value + " M^3"}
                onChange={(e, value) => act("volChange", { newVal: value })} />
            </Box>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
