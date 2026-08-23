/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */

import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { TankInfo } from '../../components/goonstation/TankInfo';
import { Window } from '../../layouts';

export const TTV = () => {
  const { act, data } = useBackend<TransferValveParams>();
  const { opened, tank_one, tank_two } = data;
  return (
    <Window width={560} height={175}>
      <Window.Content>
        <Stack>
          <Stack.Item>
            <TankInfo tank={tank_one} tankNum={1} />
          </Stack.Item>
          <Stack.Item>
            <Section title="Valve">
              <Stack vertical textAlign="center">
                <Stack.Item color={opened ? 'red' : 'green'}>
                  Valve is {opened ? 'open' : 'closed'}
                </Stack.Item>
                <Stack.Item>
                  <Button icon="repeat" onClick={() => act('toggle_valve')}>
                    Toggle Valve
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  {data.device === '' ? 'No Device ' : ''}
                  {data.device === '' ? (
                    <Button icon="add" onClick={() => act('add_item')}>
                      Add
                    </Button>
                  ) : (
                    <>
                      <Button onClick={() => act('interact_device')}>
                        {data.device}
                      </Button>
                      <Button icon="eject" onClick={() => act('remove_device')}>
                        Eject
                      </Button>
                    </>
                  )}
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <TankInfo tank={tank_two} tankNum={2} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
