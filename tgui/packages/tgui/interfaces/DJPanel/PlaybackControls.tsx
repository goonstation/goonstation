/**
 * @file
 * @copyright 2020, 2026
 * @author Original ZeWaka (https://github.com/ZeWaka)
 * @author Changes Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Button, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { DJPanelData } from './types';

const PLAYBACK_BUTTON_LINE_HEIGHT = 2.75;

export const PlaybackControls = () => {
  const { act, data } = useBackend<DJPanelData>();
  const { nowPlaying, loadedSound, soundsEnabled, looping } = data;
  return (
    <Stack align="center">
      <Stack.Item grow>
        <Button
          fluid
          textAlign="center"
          lineHeight={PLAYBACK_BUTTON_LINE_HEIGHT}
          icon="play"
          disabled={!soundsEnabled || !loadedSound}
          tooltip="Replace current music"
          onClick={() => act('play-music')}
        >
          Start Playing
        </Button>
      </Stack.Item>
      <Stack.Item grow>
        <Button
          fluid
          textAlign="center"
          lineHeight={PLAYBACK_BUTTON_LINE_HEIGHT}
          icon={nowPlaying?.paused ? 'play' : 'pause'}
          disabled={!soundsEnabled || !nowPlaying}
          onClick={() => act('toggle-pause')}
        >
          {nowPlaying?.paused ? 'Resume' : 'Pause'}
        </Button>
      </Stack.Item>
      <Stack.Item grow>
        <Button
          fluid
          textAlign="center"
          lineHeight={PLAYBACK_BUTTON_LINE_HEIGHT}
          icon="stop"
          disabled={!nowPlaying}
          onClick={() => act('stop-music')}
        >
          Stop
        </Button>
      </Stack.Item>
      <Stack.Item grow>
        <Button
          fluid
          textAlign="center"
          lineHeight={PLAYBACK_BUTTON_LINE_HEIGHT}
          icon="repeat"
          color={looping ? 'blue' : 'transparent'}
          tooltip="Repeat track"
          disabled={!soundsEnabled}
          onClick={() => act('toggle-loop')}
        >
          Loop
        </Button>
      </Stack.Item>
    </Stack>
  );
};
