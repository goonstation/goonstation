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

type PumpData = {
  net_id: string
  id: string;
  power_status: boolean;
  target_pressure: number;
  min_pressure: number;
  max_pressure: number;
  area_name: string;
}

type PumpList = {
  pump_list: PumpData[];
  frequency: number;
};

const PumpInformation = (_:any, context:any) => {
  const { act, data } = useBackend<PumpData>(context);
  const { pump } = _;

  const setPressure = (netid: string, newPressure: number) => {
    pump.target_pressure = newPressure;
    act('setPressure', { net_id: netid, pressure: newPressure });
  };
  const togglePump = (netid:string) => {
    pump.power_status = (pump.power_status === "on") ? "off" : "on";
    act('togglePump', { net_id: netid });
  };

  let pump_title = pump.id + " - " + pump.area_name;

  return (
    <Section
      title={pump_title}
      textAlign="left"
      mb={1}
      style={{
        "padding": "5px",
        "padding-top": "1px",
      }}
    >
      <Stack>
        <Stack.Item>
          <Button
            icon="power-off"
            color={(pump.power_status === 'on') ? "green" : "red"}
            onClick={() => togglePump(pump.net_id)}>
            {(pump.power_status === 'on') ? 'On' : 'Off'}
          </Button>
        </Stack.Item>
        <Stack.Item grow>
          <Slider
            value={pump.target_pressure}
            minValue={pump.min_pressure}
            maxValue={pump.max_pressure}
            unit={"kPa"}
            stepPixelSize={0.05}
            onChange={(_e: any, value: number) => setPressure(pump.net_id, value)}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const PumpControl = (props, context) => {
  const { act, data } = useBackend<PumpList>(context);
  const refresh = () => act('refresh');

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
        {data.pump_list.map((p) => (
          <PumpInformation pump={p} key={p.net_id} />
        ))}
      </Window.Content>
    </Window>
  );

};
