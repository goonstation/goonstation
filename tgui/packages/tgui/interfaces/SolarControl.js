import { useBackend } from '../backend';
import { Button, Chart, Divider, Knob, LabeledControls, LabeledList, Stack } from '../components';
import { formatPower } from '../format';
import { Window } from '../layouts';

export const SolarControl = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    power,
    orientation,
    dirname,
    trackrate,
    name,
    history,
    trackmode,
    panelcount,
  } = data;

  const powerHistory = history;
  const powerHistoryData = powerHistory.map((v, i) => [i, v]);
  const powermax = Math.max(...powerHistory);

  return (
    <Window
      width={375}
      height={400}
      title={name}
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="Solar Array Output">{formatPower(power)}</LabeledList.Item>
            </LabeledList>
            <Chart.Line
              mt="5px"
              height="5em"
              data={powerHistoryData}
              rangeX={[0, 50]}
              rangeY={[0, powermax]}
              strokeColor="rgba(1, 184, 170, 1)"
              fillColor="rgba(1, 184, 170, 0.25)"
            />
          </Stack.Item>
          <Stack.Item>
            <LabeledList />
            <Divider />
          </Stack.Item>
          <Stack.Item>
            <Stack vertical>
              <LabeledControls mx="7%" mb="5%">
                <LabeledControls.Item textalign="center" inline label={"Rotation ("+dirname+")"}>
                  <Button color="transparent" icon="angle-double-left" onClick={() => act('set_orientation', { dir: orientation-15 })} />
                  <Button color="transparent" icon="angle-left" onClick={() => act('set_orientation', { dir: orientation-1 })} />
                  {orientation}
                  <Button color="transparent" icon="angle-right" onClick={() => act('set_orientation', { dir: orientation+1 })} />
                  <Button color="transparent" icon="angle-double-right" onClick={() => act('set_orientation', { dir: orientation+15 })} />

                  <Divider />
                  <Knob
                    size={2}
                    minValue={0}
                    maxValue={360}
                    animated
                    value={orientation}
                    format={value => value + "°"}
                    onDrag={(e, value) => act('set_orientation', { dir: value })} />
                </LabeledControls.Item>
                <LabeledControls.Item inline label="Tracking Speed (°/h)">
                  <Button color="transparent" icon="angle-double-left" onClick={() => act('set_trackrate', { dir: trackrate-15 })} />
                  <Button color="transparent" icon="angle-left" onClick={() => act('set_trackrate', { dir: trackrate-1 })} />
                  {trackrate}
                  <Button color="transparent" icon="angle-right" onClick={() => act('set_trackrate', { dir: trackrate+1 })} />
                  <Button color="transparent" icon="angle-double-right" onClick={() => act('set_trackrate', { dir: trackrate+15 })} />
                  <Divider />
                  <Knob
                    size={2}
                    minValue={-7200}
                    maxValue={7200}
                    animated
                    value={trackrate}
                    format={value => value + "°/h"}
                    onDrag={(e, value) => act('set_trackrate', { dir: value })} />
                </LabeledControls.Item>
              </LabeledControls>
              <Divider />
              <LabeledControls mx="2%">
                <LabeledControls.Item inline label={panelcount+" Connected"}>
                  <Button onClick={() => act('relink', {})}>Re-Link Panels</Button>
                </LabeledControls.Item>
                <LabeledControls.Item inline label="Tracking Mode">
                  <Button disabled={trackmode===0} onClick={() => act('set_trackmode', { track: 0 })}>Off</Button>
                  <Button disabled={trackmode===1} onClick={() => act('set_trackmode', { track: 1 })}>Timed</Button>
                  <Button disabled={trackmode===2} onClick={() => act('set_trackmode', { track: 2 })}>Auto</Button>
                </LabeledControls.Item>
              </LabeledControls>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
