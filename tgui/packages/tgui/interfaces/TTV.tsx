/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Button, Section, Stack } from '../components';
import { Window } from '../layouts';
import { toTitleCase } from '../../common/string';

interface AirVendorParams {
  opened: boolean;
  tank_one: string;
  tank_two: string;
  device: string;
}

const TankInfo = (_props, context) => {
  const { act, data } = useBackend<AirVendorParams>(context);
  const { tank, tank_num } = _props;
  return (
    <Section>
      <Stack vertical align="center" textAlign="center">
        <Stack.Item>
          {tank_num === 1 ? "Tank One:" : "Tank Two:"}
        </Stack.Item>
        <Stack.Item>
          {tank ? toTitleCase(tank) : "None"}
        </Stack.Item>
        <Stack>
          <Stack.Item py={1}>
            {tank ? <Button disabled={tank === null} icon="eject" onClick={() => act(tank_num === 1 ? "remove_tank_one" : "remove_tank_two")}>Eject</Button>
              : <Button icon="add" onClick={() => act("add_item", { "tank": tank_num })}>Add</Button>}
          </Stack.Item>
        </Stack>
      </Stack>
    </Section>
  );
};

export const TTV = (_props, context) => {
  const { act, data } = useBackend<AirVendorParams>(context);
  const {
    opened,
    tank_one,
    tank_two,
  } = data;
  let windowWidth = 600;
  return (
    <Window width={windowWidth} height={150}>
      <Window.Content>
        <Section>
          <Stack>

            <Stack.Item width={windowWidth/3}>
              <TankInfo tank={tank_one} tank_num={1} />
            </Stack.Item>

            <Stack.Item width={windowWidth/3}>
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
                  {(data.device === '') ? "No Device Attached" : ''}
                  {(data.device === '') ? <Button icon="add" onClick={() => act("add_item")}>Add</Button>
                    : <><Button>{toTitleCase(data.device)}</Button><Button icon="eject" onClick={() => act("remove_device")}>Eject</Button></>}
                </Stack.Item>
              </Stack>
            </Stack.Item>

            <Stack.Item width={windowWidth/3}>
              <TankInfo tank={tank_two} tank_num={2} />
            </Stack.Item>

          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
