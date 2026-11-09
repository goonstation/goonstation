/**
 * @file
 * @copyright 2020, 2026
 * @author Original ZeWaka (https://github.com/ZeWaka)
 * @author Changes Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Button, Divider, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { DJPanelData } from './types';

export const OtherPlayback = () => {
  const { act, data } = useBackend<DJPanelData>();
  const { loadedSound, soundsEnabled } = data;
  return (
    <Section title="Other Audio">
      <Stack>
        <Stack.Item grow>
          <Button
            fluid
            textAlign="center"
            icon="volume-up"
            disabled={!soundsEnabled || !loadedSound}
            tooltip="Play to everyone"
            onClick={() => act('play-sound')}
          >
            Play Sound
          </Button>
        </Stack.Item>
        <Stack.Item grow>
          <Button
            fluid
            textAlign="center"
            icon="location-pin"
            disabled={!soundsEnabled || !loadedSound}
            tooltip="Play around you"
            onClick={() => act('play-ambience')}
          >
            Ambience
          </Button>
        </Stack.Item>
        <Stack.Item grow>
          <Button
            fluid
            textAlign="center"
            icon="user"
            disabled={!soundsEnabled || !loadedSound}
            tooltip="Play around a player"
            onClick={() => act('play-player')}
          >
            At Player
          </Button>
        </Stack.Item>
        <Stack.Item grow>
          <Button
            fluid
            textAlign="center"
            icon="globe"
            disabled={!soundsEnabled}
            tooltip="Play a YouTube URL"
            onClick={() => act('play-remote')}
          >
            Remote Music
          </Button>
        </Stack.Item>
      </Stack>
      <Divider />
      <Stack align="center">
        <Stack.Item grow>
          <Button
            icon="broadcast-tower"
            color="bad"
            onClick={() => act('stop-radio')}
          >
            Stop Radio
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button icon="stop" color="bad" onClick={() => act('stop-all')}>
            Stop All Admin Audio
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
