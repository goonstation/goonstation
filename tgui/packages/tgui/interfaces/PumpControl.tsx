/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */
// ^ dont need to ask me or anything i just assume this comes with making a new file

import { useBackend } from '../backend';
import { Button, Section, Slider, Stack } from '../components';
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
}

type PumpList = {
  area_name: string;
}

// List of areas which have pumps
type AreaList = {
  area_list: PumpList[];
  frequency: number;
};

// Responsible for providing information and settings for a pump.
const PumpSettings = (_:any, context:any) => {
  const { act, data } = useBackend<PumpData>(context);
  const { pump } = _;

  const setPressure = (netid: string, newPressure: number) => {
    pump.target_output = newPressure;
    act('setPressure', { netid: netid, pressure: newPressure });
  };
  const togglePump = (netid:string) => {
    pump.power = (pump.power === "on") ? "off" : "on";
    act('togglePump', { netid: netid });
  };

  return (
    <Stack>
      <Stack.Item>
        <Button
          width={4}
          icon="power-off"
          color={(pump.power === 'on') ? "green" : "red"}
          onClick={() => togglePump(pump.netid)}>
          {(pump.power === 'on') ? 'On' : 'Off'}
        </Button>
      </Stack.Item>
      <Stack.Item grow>
        <Slider
          value={pump.target_output}
          minValue={pump.min_output}
          maxValue={pump.max_output}
          unit={"kPa"}
          stepPixelSize={0.05}
          onChange={(_e: any, value: number) => setPressure(pump.netid, value)}
        />
        {pump.netid}
      </Stack.Item>
    </Stack>
  );
};

// Responsible for creating a section for the pumps in an area.
const PumpArea = (_:any, context:any) => {
  const { data } = useBackend<PumpList>(context);
  const { area } = _;

  return (<br />);

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
      {data[area].map((p) => (
        <PumpSettings pump={data[area][p]} key={p} />
      ))}
    </Section>
  );
};

// Main element, responsible for building the window.
export const PumpControl = (props, context) => {
  const { act, data } = useBackend<AreaList>(context);
  const refresh = () => act('refresh');
  // Check it out with --dev, but data consists of a list keyed by area names,
  // who reference lists keyed by netids, containing pump info. Yeah
  let last_key:PumpList;
  let settings = [];
  for (let key in data.area_list) {
    last_key = data.area_list[key];
    for (let pump_key in data.area_list[key]) {
      settings.push(pump_key);
    }
    settings = settings.map((a) => (<PumpSettings pump={data.area_list[key][a]} key={a} />));
  }
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
        {settings}
      </Window.Content>
    </Window>
  );

};
