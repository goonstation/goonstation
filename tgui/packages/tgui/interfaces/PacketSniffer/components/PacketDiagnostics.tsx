/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { TerminalReadout } from '../../../components/goonstation/TerminalReadout';
import type { PacketLog } from '../type';
import { PacketText } from './PacketText';

export const PacketDiagnostics = (props: {
  packet: PacketLog;
  connected: BooleanLike;
  inBuffer: boolean;
}) => {
  const { packet, connected, inBuffer } = props;
  const fileSize = packet.file?.size;
  let fileStatus = 'NONE';
  if (packet.file) {
    if (packet.file.content === null) {
      fileStatus = 'NOT PRINTABLE';
    } else if (packet.file.content === '') {
      fileStatus = 'EMPTY TEXT';
    } else {
      fileStatus = 'TEXT AVAILABLE';
    }
  }

  return (
    <Section title="FRAME TELEMETRY // INTERCEPT STATE">
      <Stack vertical>
        <Stack.Item color={connected ? 'good' : 'average'}>
          <PacketText>
            <TerminalReadout
              tag={connected ? '[LIVE]' : '[HOLD]'}
              label="CAPTURE ENGINE"
              value={connected ? 'LISTENING' : 'LINK OFFLINE'}
            />
          </PacketText>
        </Stack.Item>
        <Stack.Item color={inBuffer ? 'label' : 'average'}>
          <PacketText>
            <TerminalReadout
              tag="[HOLD]"
              label="SNAPSHOT"
              value={inBuffer ? 'IN LIVE BUFFER' : 'BUFFER ROLLED OVER'}
            />
          </PacketText>
        </Stack.Item>
        {packet.device && (
          <Stack.Item color="label">
            <PacketText>
              <TerminalReadout
                tag="[DEVC]"
                label="SOURCE PROFILE"
                value={packet.device}
              />
            </PacketText>
          </Stack.Item>
        )}
        <Stack.Item color="label">
          <PacketText>
            <TerminalReadout
              tag="[READ]"
              label="PAYLOAD MAP"
              value={`${packet.fields.length} FIELDS / ${packet.payload_length} CHARS`}
            />
          </PacketText>
        </Stack.Item>
        <Stack.Item color={packet.file ? 'average' : 'label'}>
          <PacketText>
            <TerminalReadout
              tag="[FILE]"
              label="ATTACHMENT"
              value={`${fileStatus}${fileSize === undefined ? '' : ` / ${fileSize} KB`}`}
            />
          </PacketText>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
