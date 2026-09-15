/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import type { PacketLog } from '../type';
import { PacketText } from './PacketText';

export const PacketDiagnostics = (props: {
  packet: PacketLog;
  connected: BooleanLike;
  inBuffer: boolean;
}) => {
  const { packet, connected, inBuffer } = props;
  const fileSize = packet.file?.size;

  return (
    <Section title="FRAME TELEMETRY // INTERCEPT STATE">
      <Stack vertical>
        <Stack.Item color={connected ? 'good' : 'average'}>
          <PacketText>
            {connected
              ? '[LIVE] CAPTURE ENGINE .. LISTENING'
              : '[HOLD] CAPTURE ENGINE .. LINK OFFLINE'}
          </PacketText>
        </Stack.Item>
        <Stack.Item color={inBuffer ? 'label' : 'average'}>
          <PacketText>
            {inBuffer
              ? '[HOLD] SNAPSHOT ........ IN LIVE BUFFER'
              : '[HOLD] SNAPSHOT ........ BUFFER ROLLED OVER'}
          </PacketText>
        </Stack.Item>
        {packet.device && (
          <Stack.Item color="label">
            <PacketText>[DEVC] SOURCE PROFILE .. {packet.device}</PacketText>
          </Stack.Item>
        )}
        <Stack.Item color="label">
          <PacketText>
            [READ] PAYLOAD MAP ..... {packet.fields.length} FIELDS /{' '}
            {packet.payload_length} CHARS
          </PacketText>
        </Stack.Item>
        <Stack.Item color={packet.file ? 'average' : 'label'}>
          <PacketText>
            {'[FILE] ATTACHMENT ...... ' +
              (!packet.file
                ? 'NONE'
                : packet.file.content === null
                  ? 'NOT PRINTABLE'
                  : packet.file.content === ''
                    ? 'EMPTY TEXT'
                    : 'TEXT AVAILABLE') +
              (fileSize === undefined ? '' : ' / ' + fileSize + ' KB')}
          </PacketText>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
