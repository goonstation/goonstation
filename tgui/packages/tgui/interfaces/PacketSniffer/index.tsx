/**
 * @file
 * @copyright 2025-2026
 * @author Original FlameArrow57 (https://github.com/FlameArrow57)
 * @author Changes Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { useState } from 'react';
import { Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { CaptureBuffer } from './components/CaptureBuffer';
import { CaptureStatus } from './components/CaptureStatus';
import { PacketInspector } from './components/PacketInspector';
import { SenderMask } from './components/SenderMask';
import type { FilterProps, PacketInfo, PacketLog } from './type';
import { formatPacketText } from './utils';

export const PacketSniffer = () => {
  const { act, data } = useBackend<PacketInfo>();
  const [search, setSearch] = useState('');
  // Hold the inspected frame when the device's rolling buffer replaces it.
  const [inspected, setInspected] = useState<PacketLog | null>(null);
  const {
    connected,
    packet_logs = [],
    captured_packets,
    max_logs,
    filter,
  } = data;
  const query = search.trim().toLowerCase();
  const packets = packet_logs
    .filter(
      (packet) =>
        !query ||
        [packet.device, formatPacketText(packet)]
          .join(' ')
          .toLowerCase()
          .includes(query),
    )
    .reverse();
  const filterProps: FilterProps = {
    filter,
    onFilter: (address) =>
      address === filter
        ? act('clear_filter')
        : act('set_filter_direct', { filter: address }),
  };

  return (
    <Window
      title="Packet Sniffer // Wiretap Console"
      width={800}
      height={670}
      theme="hackerman"
    >
      <Window.Content fontFamily="monospace">
        <Stack fill vertical>
          <Stack.Item>
            <CaptureStatus
              connected={connected}
              buffered={packet_logs.length}
              captured={captured_packets}
              capacity={max_logs}
              filtered={!!filter}
            />
          </Stack.Item>
          <Stack.Item>
            <SenderMask
              filter={filter}
              search={search}
              onSetFilter={(address) =>
                address
                  ? act('set_filter_direct', { filter: address })
                  : act('clear_filter')
              }
              onClearFilter={() => act('clear_filter')}
              onSearch={setSearch}
            />
          </Stack.Item>
          <Stack.Item grow minHeight={0}>
            <CaptureBuffer
              packets={packets}
              packetCount={packet_logs.length}
              connected={connected}
              inspectedSequence={inspected?.sequence}
              onInspect={setInspected}
              onPurge={() => {
                setInspected(null);
                act('clear_logs');
              }}
              {...filterProps}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
      {inspected && (
        <PacketInspector
          packet={inspected}
          connected={connected}
          inBuffer={packet_logs.some(
            (packet) => packet.sequence === inspected.sequence,
          )}
          onClose={() => setInspected(null)}
          {...filterProps}
        />
      )}
    </Window>
  );
};
