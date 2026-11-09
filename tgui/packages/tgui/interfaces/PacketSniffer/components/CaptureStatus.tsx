/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Box, Icon, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

export const CaptureStatus = (props: {
  connected: BooleanLike;
  buffered: number;
  captured: number;
  capacity: number;
  filtered: boolean;
}) => {
  const { connected, buffered, captured, capacity, filtered } = props;

  return (
    <Section>
      <Stack vertical>
        <Stack.Item>
          <Stack align="center">
            <Stack.Item>
              <Icon name="terminal" />
            </Stack.Item>
            <Stack.Item grow bold>
              NT_PACKET_INTERCEPT v2.4 // DATANET CONSOLE
            </Stack.Item>
            <Stack.Item color={connected ? 'good' : 'average'}>
              <Icon name="circle" />
            </Stack.Item>
            <Stack.Item color={connected ? 'good' : 'average'} bold>
              {connected ? 'RX ACTIVE' : 'LINK DOWN'}
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item color="label">
          WIRED NETWORK ANALYSIS // {filtered ? 'FILTERED' : 'PROMISCUOUS'}{' '}
          CAPTURE
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item grow basis={0}>
              <Stack align="center">
                <Stack.Item color={connected ? 'good' : 'average'}>
                  <Icon name={connected ? 'link' : 'unlink'} />
                </Stack.Item>
                <Stack.Item>
                  <Box color="label">[LINK] DATA TAP</Box>
                  <Box color={connected ? 'good' : 'average'} bold>
                    {connected ? 'LINKED' : 'OFFLINE'}
                  </Box>
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item grow basis={0} color="good">
              <Stack align="center">
                <Stack.Item>
                  <Icon name="database" />
                </Stack.Item>
                <Stack.Item>
                  <Box color="label">[MEM] FRAME BUFFER</Box>
                  <Box bold>
                    {String(buffered).padStart(2, '0')}/
                    {String(capacity).padStart(2, '0')}
                  </Box>
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item grow basis={0} color="good">
              <Stack align="center">
                <Stack.Item>
                  <Icon name="network-wired" />
                </Stack.Item>
                <Stack.Item>
                  <Box color="label">[RX] TOTAL CAPTURED</Box>
                  <Box bold>{String(captured).padStart(4, '0')}</Box>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
