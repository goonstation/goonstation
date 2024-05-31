/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { useBackend, useLocalState } from '../../backend';
import { Button, LabeledList, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { TankInfo } from "../TTV";

// Returns whether the nth bit starting with 0 for the rightmost is set
const is_set = (bits, bit) => { return bits & (1 << bit); };

const MaintenencePanel = (props, context) => {
  const { act, data } = useBackend<SimulatorData>(context);
  let resetButton = <Button icon="wifi" onClick={() => reset()}>Reset Connection</Button>;
  const reset = () => {
    act("reset");
    setConnection("NO CONNECTION");
  };
  const [bits, setBits] = useLocalState(context, "bits", data.net_number);
  const [connection, setConnection] = useLocalState(context, "connection", "OK CONNECTION");
  if (connection === "NO CONNECTION" && data.host_id !== null) {
    setConnection("OK CONNECTION");
  }
  return (
    <Section title="Maintenence Panel" buttons={resetButton}>
      <LabeledList.Item label="Host Connection">
        {connection}
      </LabeledList.Item>
      <LabeledList.Item label="Configuration Switches" verticalAlign="middle">
        <Stack>
          <Stack.Item><ConfigSwitch local_bits={bits} setter={setBits} bit_pos={0} /></Stack.Item>
          <Stack.Item><ConfigSwitch local_bits={bits} setter={setBits} bit_pos={1} /></Stack.Item>
          <Stack.Item><ConfigSwitch local_bits={bits} setter={setBits} bit_pos={2} /></Stack.Item>
          <Stack.Item><ConfigSwitch local_bits={bits} setter={setBits} bit_pos={3} /></Stack.Item>
        </Stack>
      </LabeledList.Item>
    </Section>
  );

};

const ConfigSwitch = (props, context) => {
  const { act, data } = useBackend<SimulatorData>(context);
  const { local_bits, setter, bit_pos } = props;
  let bit_is_set = is_set(local_bits, bit_pos);
  const handle_click = () => {
    act("config_switch", { "switch_flicked": bit_pos });
    setter(local_bits ^ (1 << bit_pos));
  };
  return (
    <Button width={2} height={2} color={(bit_is_set) ? "green" : "red"} onClick={handle_click} />
  );
};

export const Bombsim = (_props, context) => {
  const { act, data } = useBackend<SimulatorData>(context);
  let simulationButton = <Button icon="burst" disabled={!data.is_ready} onClick={() => act("simulate")}>Begin Simulation</Button>;
  return (
    <Window width={400} height={(data.panel_open) ? 400 : 300}>
      <Window.Content>
        <Stack>
          <Stack.Item>
            <TankInfo tank={data.tank_one} tankNum={1} />
          </Stack.Item>
          <Stack.Item>
            <TankInfo tank={data.tank_two} tankNum={2} />
          </Stack.Item>
        </Stack>
        <Section
          mt={1}
          title="Simulator"
          buttons={simulationButton}
        >
          <LabeledList>
            <LabeledList.Item label="Simulation">
              {(data.vr_bomb !== null) ? "ACTIVE" : "INACTIVE"}
            </LabeledList.Item>
            <LabeledList.Item label="Status">
              {data.readiness_dialogue}
            </LabeledList.Item>
            <LabeledList.Item label="Cooldown">
              {(data.is_ready) ? "None" : data.cooldown}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {(data.panel_open) ? <MaintenencePanel /> : ""}
      </Window.Content>
    </Window>
  );
};
