/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Box, Button, Modal, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import type { FilterProps, PacketLog } from '../type';
import { formatPacketText } from '../utils';
import { PacketDossier } from './PacketDossier';

export const PacketInspector = (
  props: FilterProps & {
    packet: PacketLog;
    connected: BooleanLike;
    inBuffer: boolean;
    onClose: () => void;
  },
) => {
  const { packet, connected, inBuffer, onClose, ...filterProps } = props;

  const copyToClipboard = (text: string | null | undefined) => {
    if (text === null || text === undefined) {
      return;
    }
    navigator.clipboard?.writeText(text).catch(() => undefined);
  };

  return (
    <Box onClick={onClose}>
      <Modal onEscape={onClose}>
        <Box
          width="90vw"
          fontFamily="monospace"
          onClick={(event) => event.stopPropagation()}
        >
          <Section
            title={'INSPECT #' + packet.sequence + ' // ' + packet.stamp}
            buttons={
              <>
                <Button
                  icon="copy"
                  color="transparent"
                  tooltip="Copy complete frame"
                  onClick={() => copyToClipboard(formatPacketText(packet))}
                >
                  COPY FRAME
                </Button>
                <Button icon="times" color="transparent" onClick={onClose}>
                  CLOSE
                </Button>
              </>
            }
          >
            <Box maxHeight="70vh" overflowY="auto" overflowX="hidden">
              <PacketDossier
                packet={packet}
                connected={connected}
                inBuffer={inBuffer}
                onCopy={copyToClipboard}
                {...filterProps}
              />
            </Box>
          </Section>
        </Box>
      </Modal>
    </Box>
  );
};
