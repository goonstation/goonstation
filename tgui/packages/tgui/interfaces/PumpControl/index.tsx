/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */

import { useState } from 'react';
import { Button, Section, Slider, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';

// Responsible for providing information and settings for a pump.
const PumpSettings = (props) => {
  const { act } = useBackend<PumpData>();
  const { pump } = props;
  // Local states allow to keep the appearance of seamless response, but do not cope well with button spamming
  const [target_output, setOutput] = useState(pump.target_output);
  const [power, setPower] = useState(pump.power);

  const setPressure = (newPressure: number) => {
    setOutput(newPressure);
    act('setPressure', { netid: pump.netid, pressure: newPressure });
  };
  const togglePump = () => {
    setPower(power === 'on' ? 'off' : 'on');
    act('togglePump', { netid: pump.netid });
  };

  return (
    <Stack.Item>
      <Stack vertical>
        <Stack.Item>
          <Stack>
            <Stack.Item>{pump.tag}</Stack.Item>
            <Stack.Item textAlign="right" grow={1}>
              {pump.alive === -1 ? 'Establishing Connection...' : 'Connected'}
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Button
                width={4}
                icon="power-off"
                color={power === 'on' ? 'green' : 'red'}
                onClick={() => togglePump()}
              >
                {power === 'on' ? 'On' : 'Off'}
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Slider
                value={target_output}
                minValue={pump.min_output}
                maxValue={pump.max_output}
                unit="kPa"
                stepPixelSize={0.05}
                onChange={(_e, value) => setPressure(value)}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

// Responsible for creating a section for the pumps in an area.
const PumpArea = (props) => {
  const { data } = useBackend<AreaList>();
  const { area } = props;

  // Need the keys as a list >:(
  const pump_controls = Object.entries(data.area_list[area])
    .filter(([_, pump]) => pump.alive !== 0)
    .map(([pump_key, pump]) => <PumpSettings key={pump_key} pump={pump} />);

  return (
    <Section title={area}>
      <Stack vertical>
        {pump_controls.length > 0 ? (
          pump_controls
        ) : (
          <Stack.Item>
            No pumps found for {area}, please refresh and check connection.
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};

// Main element, responsible for building the window.
export const PumpControl = () => {
  const { act, data } = useBackend<AreaList>();
  const refresh = () => act('refresh');

  // Need this as list >:(
  let areas: string[] = [];
  for (let area in data.area_list) areas.push(area);

  return (
    <Window title="Pump Control Computer" width={400} height={550}>
      <Window.Content scrollable>
        <Section>
          <Button icon="wifi" onClick={() => refresh()}>
            Requery Pumps
          </Button>
        </Section>
        {areas.map((area) => (
          <PumpArea area={area} key={area} />
        ))}
      </Window.Content>
    </Window>
  );
};
