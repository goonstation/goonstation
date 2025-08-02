/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */

import { useState } from 'react';
import { Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { TankInfo } from '../../components/goonstation/TankInfo';
import { Window } from '../../layouts';

// Returns whether the nth bit starting with 0 for the rightmost is set
const is_set = (bits: number, bit: number) => {
  return bits & (1 << bit);
};

const MaintenencePanel = () => {
  const { act, data } = useBackend<SimulatorData>();
  let resetButton = (
    <Button icon="wifi" onClick={() => reset()}>
      Reset Connection
    </Button>
  );
  const reset = () => {
    act('reset');
    setConnection('NO CONNECTION');
  };
  const [bits, setBits] = useState(data.net_number);
  const [connection, setConnection] = useState('OK CONNECTION');
  if (connection === 'NO CONNECTION' && data.host_id !== null) {
    setConnection('OK CONNECTION');
  }
  return (
    <Section title="Maintenence Panel" buttons={resetButton}>
      <LabeledList.Item label="Host Connection">{connection}</LabeledList.Item>
      <LabeledList.Item label="Configuration Switches" verticalAlign="middle">
        <Stack>
          <Stack.Item>
            <ConfigSwitch local_bits={bits} setter={setBits} bit_pos={0} />
          </Stack.Item>
          <Stack.Item>
            <ConfigSwitch local_bits={bits} setter={setBits} bit_pos={1} />
          </Stack.Item>
          <Stack.Item>
            <ConfigSwitch local_bits={bits} setter={setBits} bit_pos={2} />
          </Stack.Item>
          <Stack.Item>
            <ConfigSwitch local_bits={bits} setter={setBits} bit_pos={3} />
          </Stack.Item>
        </Stack>
      </LabeledList.Item>
    </Section>
  );
};

const ConfigSwitch = (props) => {
  const { act } = useBackend<SimulatorData>();
  const { local_bits, setter, bit_pos } = props;
  let bit_is_set = is_set(local_bits, bit_pos);
  const handle_click = () => {
    act('config_switch', { switch_flicked: bit_pos });
    setter(local_bits ^ (1 << bit_pos));
  };
  return (
    <Button
      width={2}
      height={2}
      color={bit_is_set ? 'green' : 'red'}
      onClick={handle_click}
    />
  );
};

export const Bombsim = () => {
  const { act, data } = useBackend<SimulatorData>();
  let simulationButton = (
    <Button
      icon="burst"
      disabled={!data.is_ready}
      onClick={() => act('simulate')}
    >
      Begin Simulation
    </Button>
  );
  return (
    <Window width={400} height={data.panel_open ? 400 : 300}>
      <Window.Content>
        <Stack>
          <Stack.Item>
            <TankInfo tank={data.tank_one} tankNum={1} />
          </Stack.Item>
          <Stack.Item>
            <TankInfo tank={data.tank_two} tankNum={2} />
          </Stack.Item>
        </Stack>
        <Section mt={1} title="Simulator" buttons={simulationButton}>
          <LabeledList>
            <LabeledList.Item label="Simulation">
              {data.vr_bomb !== null ? 'ACTIVE' : 'INACTIVE'}
            </LabeledList.Item>
            <LabeledList.Item label="Status">
              {data.readiness_dialogue}
            </LabeledList.Item>
            <LabeledList.Item label="Cooldown">
              {data.is_ready ? 'None' : data.cooldown}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {data.panel_open ? <MaintenencePanel /> : ''}
      </Window.Content>
    </Window>
  );
};
