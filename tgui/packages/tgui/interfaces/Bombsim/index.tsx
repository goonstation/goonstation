/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { useBackend, useLocalState } from '../../backend';
import { Button, LabeledList, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { formatPressure, truncate } from '../../format';

const TankDisplay = (props, context) => {
  const { act, data } = useBackend<TransferValveParams>(context);
  const { tankNum } = props;
  let tank:TankData = (tankNum === "1") ? (data.tank_one) : (data.tank_two);
  let hasTank = (tank.name !== null);
  let tankButton = <Button icon={(hasTank) ? "eject" : "add"} onClick={() => act("interact_tank_slot", { "slot_num": tankNum })}>{hasTank ? "Eject" : "Insert"}</Button>;
  return (
    <Section
      title={(tankNum === "1") ? "Tank One" : "Tank Two"}
      textAlign="left"
      buttons={tankButton}
      style={{
        "height": "100%",
      }}
    >
      <LabeledList>
        <LabeledList.Item
          label="Tank"
          textAlign="left"
        >
          {hasTank ? truncate(tank.name, 100) : "None"}
        </LabeledList.Item>
        <LabeledList.Item
          label="Pressure"
          textAlign="left"
        >
          {(tank.pressure !== null) ? formatPressure(tank.pressure) : "None"}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

// Returns whether the nth bit starting with 0 for the rightmost is set
const is_set = (bits, bit) => { return bits & (1 << bit); };

const MaintenencePanel = (props, context) => {
  const { act, data } = useBackend<SimulatorData>(context);
  let resetButton = <Button icon="wifi" onClick={() => act("reset")}>Reset Connection</Button>;
  const [bits, setBits] = useLocalState(context, "bits", data.net_number);
  let configSwitches = [];
  for (let i = 0; i < 4; i++) {
    configSwitches.push(<Stack.Item><ConfigSwitch local_bits={bits} setter={setBits} bit_pos={i} /></Stack.Item>);
  }
  return (
    <Section title="Maintenence Panel" buttons={resetButton}>
      <LabeledList.Item label="Host Connection">
        {(data.host_id !== null) ? "OK CONNECTION" : "NO CONNECTION"}
      </LabeledList.Item>
      <LabeledList.Item label="Configuration Switches" verticalAlign="middle">
        <Stack>
          {configSwitches}
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
  let simulationButton = <Button icon="add" disabled={!data.is_ready} onClick={() => act("simulate")}>Begin Simulation</Button>;
  return (
    <Window width={400} height={(data.panel_open) ? 400 : 300}>
      <Window.Content>
        <Stack>
          <Stack.Item>
            <TankDisplay tankNum="1" />
          </Stack.Item>
          <Stack.Item>
            <TankDisplay tankNum="2" />
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
