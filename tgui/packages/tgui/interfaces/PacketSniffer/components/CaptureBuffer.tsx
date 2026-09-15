/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Button, Icon, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import type { FilterProps, PacketLog } from '../type';
import { CaptureStandby } from './CaptureStandby';
import { TrafficStream } from './TrafficStream';

type CaptureBufferProps = FilterProps & {
  packets: PacketLog[];
  packetCount: number;
  connected: BooleanLike;
  inspectedSequence: number | undefined;
  onInspect: (packet: PacketLog) => void;
  onPurge: () => void;
};

export const CaptureBuffer = (props: CaptureBufferProps) => {
  const {
    packets,
    packetCount,
    connected,
    inspectedSequence,
    onInspect,
    onPurge,
    ...filterProps
  } = props;
  const { filter } = filterProps;

  return (
    <Section
      title={'CAPTURE BUFFER // ' + packets.length + ' FRAMES'}
      fill
      buttons={
        <Stack align="center">
          <Stack.Item color={connected ? 'good' : 'average'}>
            <Icon name="terminal" />{' '}
            {connected ? '[RX] LIVE DECODE' : '[HOLD] LINK DOWN'}
          </Stack.Item>
          <Stack.Item>
            <Button.Confirm
              icon="trash"
              color="transparent"
              disabled={!packetCount}
              confirmContent="CONFIRM PURGE"
              onClick={onPurge}
            >
              PURGE
            </Button.Confirm>
          </Stack.Item>
        </Stack>
      }
    >
      <Stack fill vertical>
        <Stack.Item grow minHeight={0}>
          <Section fill fitted scrollable>
            {packets.length ? (
              <TrafficStream
                packets={packets}
                inspectedSequence={inspectedSequence}
                onInspect={onInspect}
                {...filterProps}
              />
            ) : (
              <CaptureStandby
                connected={connected}
                filter={filter}
                hasBufferedPackets={!!packetCount}
              />
            )}
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
