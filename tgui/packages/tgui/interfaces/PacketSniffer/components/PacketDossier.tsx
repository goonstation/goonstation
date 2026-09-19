/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Button, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import type { FilterProps, PacketLog } from '../type';
import { formatPacketText } from '../utils';
import { PacketDiagnostics } from './PacketDiagnostics';
import { PacketFields } from './PacketFields';
import { PacketRouteTrace } from './PacketRouteTrace';
import { PacketText } from './PacketText';

export const PacketDossier = (
  props: FilterProps & {
    packet: PacketLog;
    connected: BooleanLike;
    inBuffer: boolean;
    onCopy: (text: string | null | undefined) => void;
  },
) => {
  const { packet, connected, inBuffer, onCopy, ...filterProps } = props;
  const decodedFields = packet.fields.filter(
    ({ key }) => key !== 'sender' && key !== 'address_1',
  );
  const frameText = formatPacketText({ ...packet, file: undefined });

  return (
    <Stack vertical>
      <Stack.Item>
        <PacketRouteTrace packet={packet} onCopy={onCopy} {...filterProps} />
      </Stack.Item>
      <Stack.Item>
        <Stack>
          <Stack.Item grow basis={0} minWidth={0}>
            <PacketDiagnostics
              packet={packet}
              connected={connected}
              inBuffer={inBuffer}
            />
          </Stack.Item>
          <Stack.Item grow basis={0} minWidth={0}>
            <Section title={'FIELD DECODE // ' + decodedFields.length}>
              <PacketFields fields={decodedFields} {...filterProps} />
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Section
          title="RAW FRAME // CAPTURED FIELD MAP"
          buttons={
            <Button
              icon="copy"
              color="transparent"
              tooltip="Copy captured fields"
              onClick={() => onCopy(frameText)}
            >
              COPY FIELDS
            </Button>
          }
        >
          <PacketText>{frameText}</PacketText>
        </Section>
      </Stack.Item>
      {packet.file && (
        <Stack.Item>
          <Section
            title="FILE BUFFER // ATTACHMENT READOUT"
            buttons={
              <Button
                icon="copy"
                color="transparent"
                disabled={packet.file.content === null}
                tooltip="Copy attachment text"
                onClick={() => onCopy(packet.file?.content)}
              >
                COPY CONTENTS
              </Button>
            }
          >
            <Stack vertical>
              <Stack.Item color="average">
                <Stack align="center">
                  <Stack.Item color="label">[FILE]</Stack.Item>
                  <Stack.Item grow minWidth={0}>
                    <PacketText>
                      {packet.file.name}.{packet.file.extension}
                    </PacketText>
                  </Stack.Item>
                  <Stack.Item color="label">{packet.file.size} KB</Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <PacketText>
                  {packet.file.content ?? '[NOT PRINTABLE]'}
                </PacketText>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      )}
      <Stack.Item color="good">
        {'> decode complete / frame isolated / awaiting operator_'}
      </Stack.Item>
    </Stack>
  );
};
