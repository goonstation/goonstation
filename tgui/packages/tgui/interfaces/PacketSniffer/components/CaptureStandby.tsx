/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Icon, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { TerminalReadout } from '../../../components/goonstation/TerminalReadout';

export const CaptureStandby = (props: {
  connected: BooleanLike;
  filter: string | null;
  destinationFilter: string | null;
  hasBufferedPackets: boolean;
}) => {
  const { connected, filter, destinationFilter, hasBufferedPackets } = props;

  return (
    <Stack fill vertical align="center" justify="center">
      <Stack.Item
        bold
        color={hasBufferedPackets || !connected ? 'average' : 'good'}
      >
        <Stack align="center">
          <Stack.Item>
            <Icon
              name={
                hasBufferedPackets
                  ? 'search'
                  : connected
                    ? 'satellite-dish'
                    : 'unlink'
              }
            />
          </Stack.Item>
          <Stack.Item>
            {hasBufferedPackets
              ? 'BUFFER QUERY // NO MATCHES'
              : connected
                ? 'AWAITING NETWORK TRAFFIC'
                : 'NO PHYSICAL DATA LINK'}
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item color="label">
        NT_PACKET_INTERCEPT // PASSIVE SURVEILLANCE
      </Stack.Item>
      <Stack.Item>
        <Stack vertical>
          <Stack.Item color={connected ? 'good' : 'average'}>
            <TerminalReadout
              tag={connected ? '[ OK ]' : '[FAIL]'}
              label="DATA TAP"
              value={connected ? 'LINK ESTABLISHED' : 'TERMINAL NOT FOUND'}
            />
          </Stack.Item>
          <Stack.Item color={filter ? 'average' : 'label'}>
            <TerminalReadout
              tag="[MASK]"
              label="SOURCE"
              value={filter || '******** / ALL SOURCES'}
            />
          </Stack.Item>
          <Stack.Item color={destinationFilter ? 'average' : 'label'}>
            <TerminalReadout
              tag="[MASK]"
              label="DESTINATION"
              value={destinationFilter || '******** / ALL DESTINATIONS'}
            />
          </Stack.Item>
          <Stack.Item color="label">
            <TerminalReadout
              tag={
                hasBufferedPackets ? '[FIND]' : connected ? '[WAIT]' : '[HOLD]'
              }
              label={hasBufferedPackets ? 'BUFFER QUERY' : 'CAPTURE ENGINE'}
              value={
                hasBufferedPackets
                  ? 'NO MATCHING FRAMES'
                  : connected
                    ? 'LISTENER ARMED'
                    : 'AWAITING UPLINK'
              }
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item color="label" textAlign="center">
        {hasBufferedPackets
          ? 'No buffered frames match this search.'
          : connected
            ? 'Listening for network packets matching both address masks.'
            : 'Attach the sniffer to an exposed data terminal to capture packets.'}
      </Stack.Item>
      <Stack.Item color={connected ? 'good' : 'average'}>
        {hasBufferedPackets
          ? '> revise buffer query_'
          : connected
            ? '> stand by for intercept_'
            : '> establish physical link_'}
      </Stack.Item>
    </Stack>
  );
};
