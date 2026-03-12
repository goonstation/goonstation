/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */

import { BooleanLike } from 'common/react';
import {
  Button,
  Modal,
  Section,
  Stack,
  Table,
  TimeDisplay,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { formatTime } from '../format';
import { Window } from '../layouts';

interface ArmoryAuthorizationData {
  disk_authed: BooleanLike;
  auths_needed: number;
  cooldown: number;
  authorization_bioholders: string[];
  authorization_names: string[];
  authed: BooleanLike;
  user_access_level: number;
}

export const ArmoryAuthorization = () => {
  const { act, data } = useBackend<ArmoryAuthorizationData>();
  return (
    <Window width={400} height={230}>
      <Window.Content>
        {data.cooldown > 0 && (
          <Modal textAlign="center" fontSize={2} p="10px">
            Armory Cooldown: <br />
            <TimeDisplay value={data.cooldown} format={formatTime} />
          </Modal>
        )}
        <Stack vertical fill>
          <Stack.Item>
            <Section title="Armory Control">
              <Button
                disabled={data.user_access_level < 1}
                onClick={() => act('auth')}
                color={
                  data.user_access_level > 1 ||
                  data.auths_needed - 1 === data.authorization_bioholders.length
                    ? 'green'
                    : 'red'
                }
              >
                {data.authed ? 'Revoke' : 'Authorize'}
              </Button>
              <Button
                disabled={data.disk_authed}
                color="green"
                icon="floppy-disk"
                onClick={() => act('disk_auth')}
              >
                {data.authed ? 'Revoke with Disk' : 'Emergency Authorization'}
              </Button>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              fill
              title={data.authed ? 'Revokations' : 'Authorizations'}
              buttons={
                <Button
                  disabled={data.user_access_level < 2}
                  color="grey"
                  onClick={() => act('repeal_all')}
                >
                  Repeal All
                </Button>
              }
            >
              <Table>
                <Table.Cell>
                  <b>Name:</b>
                </Table.Cell>
                <Table.Cell>
                  <b>DNA:</b>
                </Table.Cell>
                {data.authorization_bioholders.map((authorization, index) => (
                  <Table.Row key={index}>
                    <Table.Cell>{data.authorization_names[index]}</Table.Cell>
                    <Table.Cell>
                      {data.authorization_bioholders[index]}
                    </Table.Cell>
                    <Table.Cell py="2px">
                      <Button
                        color="grey"
                        onClick={() => act('repeal', { index: index + 1 })}
                      >
                        Repeal
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
