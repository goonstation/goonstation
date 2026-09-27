/**
 * @file
 * @copyright 2020, 2026
 * @author Original ZeWaka (https://github.com/ZeWaka)
 * @author Changes Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Mixer } from './Mixer';
import { PlaybackControls } from './PlaybackControls';
import { PlaybackDisplay } from './PlaybackDisplay';
import type { DJPanelData } from './types';

export const MusicPlayer = () => (
  <Section title="Music Deck" buttons={<DeckSettings />}>
    <Stack vertical>
      <Stack.Item>
        <PlaybackDisplay />
      </Stack.Item>
      <Stack.Item>
        <PlaybackControls />
      </Stack.Item>
      <Stack.Item>
        <Mixer />
      </Stack.Item>
    </Stack>
  </Section>
);

const DeckSettings = () => {
  const { act, data } = useBackend<DJPanelData>();
  return (
    <>
      <Button
        icon="bullhorn"
        color={data.announceMode ? 'default' : 'transparent'}
        tooltip="Show who is playing audio"
        onClick={() => act('toggle-announce')}
      >
        Announce Playback
      </Button>
      {!!data.isAdmin && (
        <Button
          icon="user-cog"
          color="transparent"
          tooltip="Manage player DJ access"
          onClick={() => act('toggle-player-dj')}
        />
      )}
    </>
  );
};
