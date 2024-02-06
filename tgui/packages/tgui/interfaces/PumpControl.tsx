/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */

import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Slider, Stack } from '../components';
// import { DataInputOptions } from './common/DataInput';
import { Window } from '../layouts';

// List of information about a pump
type PumpData = {
  tag: string; // Pump name
  netid: string; // Pump id
  power: boolean; // On or off
  target_output: number; // Current output target of the pump
  min_output: number;
  max_output: number;
  area_name: string; // Name of the area this pump is in
  processing: boolean; // Whether we are waiting for packet response or not
}

// List of areas which have pumps
type AreaList = {
  area_list: { [key: string] : { [key: string] : PumpData } };
  frequency: number;
};

// Responsible for providing information and settings for a pump.
const PumpSettings = (_:any, context:any) => {
  const { act, data } = useBackend<PumpData>(context);
  const { pump } = _;
  // Local states allow to keep the appearance of seamless response, but do not cope well with button spamming
  const [target_output, setOutput] = useLocalState(context, pump.netid+"pressure", pump.target_output);
  const [power, setPower] = useLocalState(context, pump.netid+"power", "on");

  const setPressure = (newPressure: number) => {
    setOutput(newPressure);
    act('setPressure', { netid: pump.netid, pressure: newPressure });
  };
  const togglePump = () => {
    setPower((power === "on") ? "off" : "on");
    act('togglePump', { netid: pump.netid });
  };

  return (
    <Box>
      <Stack>
        <Stack.Item
          py={1}
        >
          {pump.tag}
        </Stack.Item>
      </Stack>
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
            value={target_output}
            minValue={pump.min_output}
            maxValue={pump.max_output}
            unit={"kPa"}
            stepPixelSize={0.05}
            onChange={(_e: any, value: number) => setPressure(value)}
          />
        </Stack.Item>
      </Stack>
    </Box>
  );
};

// Responsible for creating a section for the pumps in an area.
const PumpArea = (_:any, context:any) => {
  const { data } = useBackend<AreaList>(context);
  const { area } = _;

  // Need the keys as a list >:(
  let pump_controls = [];
  for (let pump_key in data.area_list[area]) pump_controls.push(<PumpSettings pump={data.area_list[area][pump_key]} />);

  return (
    <Section
      title={area}
      textAlign="left"
      mb={1}
      style={{
        "padding": "5px",
        "padding-top": "1px",
      }}
    >
      {pump_controls}
    </Section>
  );
};

// Main element, responsible for building the window.
export const PumpControl = (props, context) => {
  const { act, data } = useBackend<AreaList>(context);
  const refresh = () => act('refresh');

  // Need this as list >:(
  let areas = [];
  for (let area in data.area_list) areas.push(area);

  return (
    <Window
      title="Pump Control Computer"
      width={400}
      height={500}>
      <Window.Content scrollable>
        <Button
          style={{
            "margin-bottom": "10px",
          }}
          onClick={() => refresh()}
        >
          Refresh
        </Button>
        {areas.map((area) => (<PumpArea area={area} key={area} />))}
      </Window.Content>
    </Window>
  );

};
