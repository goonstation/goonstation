/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */

import { useBackend, useLocalState } from '../../backend';
import { Button, Section, Slider, Stack } from '../../components';
import { Window } from '../../layouts';

// Responsible for providing information and settings for a pump.
const PumpSettings = (props:any, context:any) => {
  const { act } = useBackend<PumpData>(context);
  const { pump } = props;
  // Local states allow to keep the appearance of seamless response, but do not cope well with button spamming
  const [target_output, setOutput] = useLocalState(context, pump.netid+"pressure", pump.target_output);
  const [power, setPower] = useLocalState(context, pump.netid+"power", pump.power);

  const setPressure = (newPressure: number) => {
    setOutput(newPressure);
    act('setPressure', { netid: pump.netid, pressure: newPressure });
  };
  const togglePump = () => {
    setPower((power === "on") ? "off" : "on");
    act('togglePump', { netid: pump.netid });
  };

  return (
    <Stack.Item>
      <Stack vertical>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              {pump.tag}
            </Stack.Item>
            <Stack.Item textAlign="right" grow={1}>
              {pump.alive === -1 ? "Establishing Connection..." : "Connected"}
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Button
                width={4}
                icon="power-off"
                color={(power === 'on') ? "green" : "red"}
                onClick={() => togglePump()}>
                {(power === 'on') ? 'On' : 'Off'}
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Slider
                disabled={pump.alive !== 1}
                value={target_output}
                minValue={pump.min_output}
                maxValue={pump.max_output}
                unit="kPa"
                stepPixelSize={0.05}
                onChange={(_e: any, value: number) => setPressure(value)}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};


// Responsible for creating a section for the pumps in an area.
const PumpArea = (props: any, context: any) => {
  const { data } = useBackend<AreaList>(context);
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
          <Stack.Item>No pumps found for {area}, please refresh and check connection.</Stack.Item>
        )}
      </Stack>
    </Section>
  );
};

// Main element, responsible for building the window.
export const PumpControl = (props, context) => {
  const { act, data } = useBackend<AreaList>(context);
  const refresh = () => act('refresh');

  // Need this as list >:(
  let areas: string[] = [];
  for (let area in data.area_list) areas.push(area);

  return (
    <Window
      title="Pump Control Computer"
      width={400}
      height={550}>
      <Window.Content scrollable>
        <Section>
          <Button
            icon="wifi"
            onClick={() => refresh()}
          >
            Requery Pumps
          </Button>
        </Section>
        {areas.map((area) => (<PumpArea area={area} key={area} />))}
      </Window.Content>
    </Window>
  );
};
