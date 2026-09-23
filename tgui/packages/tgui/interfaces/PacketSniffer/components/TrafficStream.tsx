/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import type { PropsWithChildren } from 'react';
import { Box, Button, Icon, Stack } from 'tgui-core/components';

import type { FilterProps, PacketField, PacketLog } from '../type';
import { displayValue, getPacketField, getPacketSignature } from '../utils';
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
        <PacketColumns>
          <PacketColumns.Frame>[FRAME]</PacketColumns.Frame>
          <PacketColumns.Route>
            <Stack align="center">
              <Stack.Item>[SRC]</Stack.Item>
              <Stack.Item>
                <Icon name="angle-right" />
              </Stack.Item>
              <Stack.Item>[DST]</Stack.Item>
            </Stack>
          </PacketColumns.Route>
          <PacketColumns.Command>[CMD] / [DEVC]</PacketColumns.Command>
          <PacketColumns.Payload>[DATA] // FIELD DECODE</PacketColumns.Payload>
        </PacketColumns>
      </Stack.Item>
      <Stack.Item>
        <Stack vertical reverse zebra>
          {packets.map((packet) => (
            <Stack.Item key={packet.sequence}>
              <PacketColumns>
                <PacketColumns.Frame>
                  <Stack vertical>
                    <Stack.Item>
                      <Button
                        icon="hashtag"
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
                        {`${packet.sequence}`.padStart(4, '0')}
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <PacketText>{packet.stamp}</PacketText>
                    </Stack.Item>
                  </Stack>
                </PacketColumns.Frame>
                <PacketColumns.Route>
                  <PacketRoute packet={packet} {...filterProps} />
                </PacketColumns.Route>
                <PacketColumns.Command>
                  <Stack vertical>
                    <Stack.Item>
                      <Stack align="center">
                        <Stack.Item color="good">
                          <Icon name="angle-right" />
                        </Stack.Item>
                        <Stack.Item grow minWidth={0} bold>
                          <PacketText>
                            {displayValue(getPacketField(packet, 'command'))}
                          </PacketText>
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                    {packet.device && (
                      <Stack.Item>
                        <PacketText>{packet.device}</PacketText>
                      </Stack.Item>
                    )}
                  </Stack>
                </PacketColumns.Command>
                <PacketColumns.Payload>
                  <PacketPayload packet={packet} />
                </PacketColumns.Payload>
              </PacketColumns>
            </Stack.Item>
          ))}
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const PacketColumns = (props: PropsWithChildren) => (
  <Stack align="center">{props.children}</Stack>
);

PacketColumns.Frame = (props: PropsWithChildren) => (
  <Stack.Item grow basis={0} minWidth={0}>
    {props.children}
  </Stack.Item>
);

PacketColumns.Route = (props: PropsWithChildren) => (
  <Stack.Item grow={3} basis={0} minWidth={0}>
    {props.children}
  </Stack.Item>
);

PacketColumns.Command = (props: PropsWithChildren) => (
  <Stack.Item grow={2} basis={0} minWidth={0}>
    {props.children}
  </Stack.Item>
);

PacketColumns.Payload = (props: PropsWithChildren) => (
  <Stack.Item grow={3} basis={0} minWidth={0}>
    {props.children}
  </Stack.Item>
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
        <Icon name="angle-right" />
      </Stack.Item>
      <Stack.Item minWidth={0}>
        <PacketText>
          <AddressFilter
            address={getPacketField(packet, 'address_1')}
            destination
            {...filterProps}
          />
        </PacketText>
      </Stack.Item>
    </Stack>
  );
};

const PacketPayload = (props: { packet: PacketLog }) => {
  const { packet } = props;
  const signature = getPacketSignature(packet);
  const payload = packet.fields.filter(
    ({ name }) => !['sender', 'address_1', 'command', 'device'].includes(name),
  );

  return (
    <Stack vertical>
      {!!payload.length && (
        <Stack.Item>
          <PacketText>
            {payload.map((field) => (
              <PacketPayloadField key={field.name} field={field} />
            ))}
          </PacketText>
        </Stack.Item>
      )}
      {!payload.length && !packet.file && (
        <Stack.Item color="label">
          <PacketText>
            {signature === 'UNCLASSIFIED' ? 'NO EXTRA FIELDS' : signature}
          </PacketText>
        </Stack.Item>
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

const PacketPayloadField = (props: { field: PacketField }) => {
  const { name, value } = props.field;

  return (
    <>
      <Box inline color="label">
        {`${name}=`}
      </Box>
      {displayValue(value)}
      {'; '}
    </>
  );
};
