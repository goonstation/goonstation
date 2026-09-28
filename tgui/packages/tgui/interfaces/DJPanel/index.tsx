/**
 * @file
 * @copyright 2020, 2026
 * @author Original ZeWaka (https://github.com/ZeWaka)
 * @author Changes Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { NoticeBox, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { MusicPlayer } from './MusicPlayer';
import { OtherPlayback } from './OtherPlayback';
import { SoundLibrary } from './SoundLibrary';
import type { DJPanelData } from './types';

export const DJPanel = () => {
  const { data } = useBackend<DJPanelData>();
  return (
    <Window width={520} height={590} title="DJ Panel">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            {!data.soundsEnabled && (
              <NoticeBox danger>Admin sounds are disabled.</NoticeBox>
            )}
            <MusicPlayer />
          </Stack.Item>
          <Stack.Item grow minHeight={0}>
            <SoundLibrary />
          </Stack.Item>
          <Stack.Item>
            <OtherPlayback />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
