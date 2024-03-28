/**
 * @file
 * @copyright 2024
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { useBackend } from '../../backend';
import { Box, Button, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { TransceptionInterlinkData } from './type';

export const TransceptionInterlink = (_props, context) => {
  const { data, act } = useBackend<TransceptionInterlinkData>(context);
  const { pads, crate_count } = data;
  return (
    <Window title="Transception Interlink" height="340" width="400">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack>
                <Stack.Item width="100%" fontSize="1.2em">
                  {
                    crate_count !== 0 && `Pending Crates: ${crate_count}`
                  }
                  {
                    crate_count === 0 && 'No pending crates'
                  }
                </Stack.Item>
                <Stack.Item>
                  <Button icon="refresh" content="Link Transception Pads" onClick={() => act('ping')} />
                </Stack.Item>

              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item textAlign="center">
            {
              pads.length === 0 && <Section title="No Transception Pads Found"><Box>NO DEVICES DETECTED <br />Link pads to continue</Box></Section>
            }
            {
              pads.length !== 0 && pads.map(pad => (
                <Section key={pad.target_id} title={`${pad.location} ${pad.identifier}`}>
                  <Stack>
                    <Stack.Item grow>
                      <Button icon="arrow-up" content="Send" onClick={() => act('send', { device_index: pad.device_index })} />
                      <Button icon="arrow-down" content="Receive" onClick={() => act('receive', { device_index: pad.device_index })} />
                    </Stack.Item>
                    <Stack.Item width="35%" textAlign="left">STATUS: {pad.array_link}</Stack.Item>
                  </Stack>
                </Section>
              ))
            }
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
