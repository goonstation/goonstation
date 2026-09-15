/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Icon, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

export const CaptureStandby = (props: {
  connected: BooleanLike;
  filter: string | null;
  hasBufferedPackets: boolean;
}) => {
  const { connected, filter, hasBufferedPackets } = props;

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
            {connected
              ? '[ OK ] DATA TAP ........ LINK ESTABLISHED'
              : '[FAIL] DATA TAP ........ TERMINAL NOT FOUND'}
          </Stack.Item>
          <Stack.Item color={filter ? 'average' : 'label'}>
            [MASK] SENDER .......... {filter || '******** / ALL SENDERS'}
          </Stack.Item>
          <Stack.Item color="label">
            {hasBufferedPackets
              ? '[FIND] BUFFER QUERY .... NO MATCHING FRAMES'
              : connected
                ? '[WAIT] CAPTURE ENGINE .. LISTENER ARMED'
                : '[HOLD] CAPTURE ENGINE .. AWAITING UPLINK'}
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item color="label" textAlign="center">
        {hasBufferedPackets
          ? 'No buffered frames match this search.'
          : connected
            ? 'Listening for network packets matching the sender mask.'
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
