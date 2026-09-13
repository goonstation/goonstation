/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import type { ReactNode } from 'react';
import { Box, Button, Icon, Stack } from 'tgui-core/components';

import type { FilterProps, PacketLog } from '../type';
import { displayValue, getPacketField } from '../utils';
import { AddressFilter } from './AddressFilter';
import { PacketText } from './PacketText';

export const TrafficStream = (
  props: FilterProps & {
    packets: Array<PacketLog>;
    inspectedSequence: number | undefined;
    onInspect: (packet: PacketLog) => void;
  },
) => {
  const { packets, inspectedSequence, onInspect, ...filterProps } = props;

  return (
    <Stack vertical>
      <Stack.Item bold color="label">
        <PacketColumns
          frame="FRAME"
          route={
            <Stack align="center">
              <Stack.Item>SOURCE</Stack.Item>
              <Stack.Item>
                <Icon name="long-arrow-alt-right" />
              </Stack.Item>
              <Stack.Item>DESTINATION</Stack.Item>
            </Stack>
          }
          command="COMMAND / DEVICE"
          payload="PAYLOAD / OTHER FIELDS"
        />
      </Stack.Item>
      <Stack.Item>
        <Stack vertical zebra>
          {packets.map((packet) => (
            <Stack.Item key={packet.sequence}>
              <PacketColumns
                frame={
                  <Stack vertical>
                    <Stack.Item>
                      <Button
                        color={
                          packet.sequence === inspectedSequence
                            ? 'default'
                            : 'transparent'
                        }
                        textColor={
                          packet.sequence === inspectedSequence
                            ? undefined
                            : 'white'
                        }
                        selected={packet.sequence === inspectedSequence}
                        tooltip={'Inspect frame ' + packet.sequence}
                        onClick={() => onInspect(packet)}
                      >
                        #{packet.sequence}
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <PacketText>{packet.stamp}</PacketText>
                    </Stack.Item>
                  </Stack>
                }
                route={<PacketRoute packet={packet} {...filterProps} />}
                command={
                  <Stack vertical>
                    <Stack.Item>
                      <PacketText>
                        {displayValue(getPacketField(packet, 'command'))}
                      </PacketText>
                    </Stack.Item>
                    {packet.device && (
                      <Stack.Item>
                        <PacketText>{packet.device}</PacketText>
                      </Stack.Item>
                    )}
                  </Stack>
                }
                payload={<PacketPayload packet={packet} />}
              />
            </Stack.Item>
          ))}
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const PacketColumns = (props: {
  frame: ReactNode;
  route: ReactNode;
  command: ReactNode;
  payload: ReactNode;
}) => (
  <Stack align="center">
    <Stack.Item grow basis={0} minWidth={0}>
      {props.frame}
    </Stack.Item>
    <Stack.Item grow={3} basis={0} minWidth={0}>
      {props.route}
    </Stack.Item>
    <Stack.Item grow={2} basis={0} minWidth={0}>
      {props.command}
    </Stack.Item>
    <Stack.Item grow={3} basis={0} minWidth={0}>
      {props.payload}
    </Stack.Item>
  </Stack>
);

const PacketRoute = (props: FilterProps & { packet: PacketLog }) => {
  const { packet, ...filterProps } = props;
  return (
    <Stack align="center" wrap>
      <Stack.Item minWidth={0}>
        <PacketText>
          <AddressFilter
            address={getPacketField(packet, 'sender')}
            {...filterProps}
          />
        </PacketText>
      </Stack.Item>
      <Stack.Item color="label">
        <Icon name="long-arrow-alt-right" />
      </Stack.Item>
      <Stack.Item minWidth={0}>
        <PacketText>
          <AddressFilter
            address={getPacketField(packet, 'address_1')}
            {...filterProps}
          />
        </PacketText>
      </Stack.Item>
    </Stack>
  );
};

const PacketPayload = (props: { packet: PacketLog }) => {
  const { packet } = props;
  const payload = packet.fields.filter(
    ({ key }) => !['sender', 'address_1', 'command', 'device'].includes(key),
  );

  return (
    <Stack vertical>
      {!!payload.length && (
        <Stack.Item>
          <PacketText>
            {payload.map(({ key, value }, index) => (
              <Box as="span" key={index}>
                <Box as="span" color="label">
                  {key}=
                </Box>
                {displayValue(value)}
                {'; '}
              </Box>
            ))}
          </PacketText>
        </Stack.Item>
      )}
      {!payload.length && !packet.file && (
        <Stack.Item color="label">-</Stack.Item>
      )}
      {packet.file && (
        <Stack.Item color="average">
          <Stack align="center">
            <Stack.Item>
              <Icon name="file" />
            </Stack.Item>
            <Stack.Item grow minWidth={0}>
              <PacketText>
                [FILE] {packet.file.name}.{packet.file.extension} {'// '}
                {packet.file.size} KB
              </PacketText>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      )}
    </Stack>
  );
};
