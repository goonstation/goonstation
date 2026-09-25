/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Button, Icon, Section, Stack } from 'tgui-core/components';

import type { FilterProps, PacketLog } from '../type';
import { getPacketField, getPacketSignature } from '../utils';
import { AddressFilter } from './AddressFilter';
import { PacketText } from './PacketText';

export const PacketRouteTrace = (
  props: FilterProps & {
    packet: PacketLog;
    onCopy: (text: string | null | undefined) => void;
  },
) => {
  const { packet, onCopy, ...filterProps } = props;
  const destination = getPacketField(packet, 'address_1');

  return (
    <Section title="ROUTE TRACE // WIRED INTERCEPT">
      <Stack align="center">
        <Stack.Item grow basis={0} minWidth={0}>
          <Stack vertical>
            <Stack.Item color="label">
              [SRC] {packet.source_name || 'source'}
            </Stack.Item>
            <Stack.Item>
              <PacketText>
                <AddressFilter
                  address={packet.source_address ?? undefined}
                  {...filterProps}
                />
              </PacketText>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="copy"
                color="transparent"
                disabled={!packet.source_address}
                tooltip="Copy source address"
                onClick={() => onCopy(packet.source_address)}
              >
                COPY SRC
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow={2} basis={0} minWidth={0}>
          <Stack vertical align="center">
            <Stack.Item color="label">[CLASS] TRAFFIC SIGNATURE</Stack.Item>
            <Stack.Item color="good" bold textAlign="center">
              <PacketText>{getPacketSignature(packet)}</PacketText>
            </Stack.Item>
            <Stack.Item color="label">
              <Icon name="angle-right" />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow basis={0} minWidth={0}>
          <Stack vertical>
            <Stack.Item color="label">[DST] address_1</Stack.Item>
            <Stack.Item>
              <PacketText>
                <AddressFilter
                  address={destination}
                  destination
                  {...filterProps}
                />
              </PacketText>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="copy"
                color="transparent"
                disabled={!destination}
                tooltip="Copy destination address"
                onClick={() => onCopy(destination)}
              >
                COPY DST
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
