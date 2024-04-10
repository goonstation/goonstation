/**
 * @file
 * @copyright 2024
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { useBackend } from '../../backend';
import { Box, Button, LabeledList, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { TransceptionInterlinkData } from './type';

const PadStatusToColor = (status: string) => {
  switch (status) {
    case 'OK':
      return 'good';
    case 'ARRAY_POWER_LOW':
      return 'yellow';
    case 'ERR_ARRAY':
    case 'ERR_WIRE':
    case 'ERR_OTHER':
      return 'bad';
    default:
      return 'average';
  }
};

export const TransceptionInterlink = (_props, context) => {
  const { data, act } = useBackend<TransceptionInterlinkData>(context);
  const { pads, crate_count } = data;
  return (
    <Window title="Transception Interlink" height="252" width="475">
      <Window.Content>
        <Stack vertical>
          <Stack.Item>
            <Section>
              <Stack justify="space-between">
                <Stack.Item fontSize="1.2em">
                  {crate_count !== 0 && `Pending Crates: ${crate_count}`}
                  {crate_count === 0 && 'No pending crates'}
                </Stack.Item>
                <Stack.Item>
                  <Button icon="refresh" content="Link Transception Pads" onClick={() => act('ping')} />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            {pads.length === 0 && (
              <Section title="No Transception Pads Found">
                <Box>
                  NO DEVICES DETECTED <br />
                  Link pads to continue
                </Box>
              </Section>
            )}
            {pads.length !== 0 && (
              <Section title="Transception Pads">
                <LabeledList>
                  {pads.map((pad) => (
                    <LabeledList.Item
                      key={pad.device_netid}
                      label={`${pad.location} ${pad.identifier}`}
                      color={`${PadStatusToColor(pad.array_link)}`}
                      labelWrap
                      buttons={
                        <>
                          <Button
                            icon="arrow-up"
                            content="Send"
                            onClick={() => act('send', { device_netid: pad.device_netid })}
                          />
                          <Button
                            icon="arrow-down"
                            content="Receive"
                            onClick={() => act('receive', { device_netid: pad.device_netid })}
                          />
                        </>
                      }>
                      {pad.array_link}
                    </LabeledList.Item>
                  ))}
                </LabeledList>
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
