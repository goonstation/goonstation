/**
 * @file
 * @copyright 2020, 2026
 * @author Original ZeWaka (https://github.com/ZeWaka)
 * @author Changes Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Button, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { formatSiUnit } from '../../format';
import type { DJPanelData, LibrarySound, PreloadState } from './types';

const preloadLabels: Record<
  PreloadState,
  { icon: string; label: string; tooltip: string }
> = {
  none: {
    icon: 'download',
    label: 'Preload',
    tooltip: 'Download without playing',
  },
  requested: {
    icon: 'check',
    label: 'Preload Sent',
    tooltip: 'Downloads requested. Click to resend.',
  },
};

export const SoundLibraryRow = ({ sound }: { sound: LibrarySound }) => {
  const { act, data } = useBackend<DJPanelData>();
  const { loadedSound, soundsEnabled } = data;
  const { name, sizeBytes, preloadState } = sound;
  const preload = preloadLabels[preloadState];
  return (
    <Stack align="center">
      <Stack.Item grow minWidth={0}>
        <Button
          fluid
          ellipsis
          icon={name === loadedSound ? 'check' : 'music'}
          color={
            !soundsEnabled
              ? 'default'
              : name === loadedSound
                ? 'blue'
                : 'transparent'
          }
          tooltip={name}
          disabled={!soundsEnabled}
          onClick={() => act('load-sound', { name })}
        >
          {name}
        </Button>
      </Stack.Item>
      <Stack.Item color="label" minWidth={4} textAlign="right">
        {typeof sizeBytes === 'number' ? formatSiUnit(sizeBytes, 0, 'B') : '—'}
      </Stack.Item>
      <Stack.Item>
        <Button
          icon={preload.icon}
          color={
            preloadState === 'requested' && soundsEnabled
              ? 'transparent'
              : 'default'
          }
          disabled={!soundsEnabled}
          tooltip={preload.tooltip}
          onClick={() => act('preload-sound', { name })}
        >
          {preload.label}
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button.Confirm
          icon="trash"
          color="bad"
          tooltip="Remove from library"
          onClick={() => act('remove-sound', { name })}
        />
      </Stack.Item>
    </Stack>
  );
};
