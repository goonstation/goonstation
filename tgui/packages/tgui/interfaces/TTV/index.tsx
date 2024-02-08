/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { useBackend } from '../../backend';
import { Button, LabeledList, RoundGauge, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { toTitleCase } from 'common/string';
import { formatPressure } from '../../format';

const TankInfo = (_props, context) => {
  const { act } = useBackend<TransferValveParams>(context);
  const { tank } = _props;
  let button_eject = <Button width={5} textAlign={"center"} disabled={tank.name===null} icon="eject" onClick={() => act(tank.num === 1 ? "remove_tank_one" : "remove_tank_two")}>Eject</Button>;
  let button_add = <Button width={5} textAlign={"center"} icon="add" onClick={() => act("add_item", { "tank": tank.num })}>Add</Button>;
  let maxPressure = (tank.maxPressure !== null) ? tank.maxPressure : 999;
  return (
    <Section
      title={tank.num === 1 ? "Tank One" : "Tank Two"}
      buttons={tank.name !== null ? button_eject : button_add}
    >
      <LabeledList>
        <LabeledList.Item label={"Holding"}>
          {tank.name !== null ? toTitleCase(tank.name) : "None"}
        </LabeledList.Item>
        <LabeledList.Item
          label="Pressure">
          <RoundGauge
            size={1.75}
            value={tank.pressure !== null ? tank.pressure : 0}
            minValue={0}
            maxValue={maxPressure}
            alertAfter={maxPressure * 0.70}
            ranges={{
              "good": [0, maxPressure * 0.70],
              "average": [maxPressure * 0.70, maxPressure * 0.85],
              "bad": [maxPressure * 0.85, maxPressure],
            }}
            format={formatPressure}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

export const TTV = (_props, context) => {
  const { act, data } = useBackend<TransferValveParams>(context);
  const {
    opened,
    tank_one,
    tank_two,
  } = data;
  return (
    <Window width={650} height={170}>
      <Window.Content>
        <Stack>
          <Stack.Item>
            <TankInfo tank={tank_one} />
          </Stack.Item>

          <Stack.Item>
            <Section title="Valve" px={1}>
              <Stack vertical textAlign="center">
                <Stack.Item color={opened ? "red" : "green"}>
                  Valve is {opened ? "open" : "closed"}
                </Stack.Item>
                <Stack.Item>
                  <Button icon="repeat" onClick={() => act("toggle_valve")}>
                    Toggle Valve
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  {(data.device === '') ? "No Device " : ''}
                  {(data.device === '') ? <Button icon="add" onClick={() => act("add_item")}>Add</Button>
                    : <><Button onClick={() => act("interact_device")}>{data.device}</Button><Button icon="eject" onClick={() => act("remove_device")}>Eject</Button></>}
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <TankInfo tank={tank_two} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
