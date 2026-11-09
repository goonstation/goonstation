/**
 * @file
 * @copyright 2020, 2026
 * @author Original ZeWaka (https://github.com/ZeWaka)
 * @author Changes Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Box, Icon, ProgressBar, Stack, Tooltip } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { formatTime } from '../../format';
import type { DJPanelData, PlayingTrack } from './types';

const DECISECONDS_PER_SECOND = 10;
enum PlaybackState {
  Playing = 'playing',
  Paused = 'paused',
  Stopped = 'stopped',
  Offline = 'offline',
}

const STATE_ICONS: Record<PlaybackState, string> = {
  [PlaybackState.Playing]: 'play',
  [PlaybackState.Paused]: 'pause',
  [PlaybackState.Stopped]: 'stop',
  [PlaybackState.Offline]: 'volume-mute',
};

export const PlaybackDisplay = () => {
  const { data } = useBackend<DJPanelData>();
  const { nowPlaying, loadedSound, soundsEnabled } = data;
  const playbackState = !soundsEnabled
    ? PlaybackState.Offline
    : nowPlaying
      ? nowPlaying.paused
        ? PlaybackState.Paused
        : PlaybackState.Playing
      : PlaybackState.Stopped;
  const stateColor =
    playbackState === PlaybackState.Playing
      ? 'blue'
      : playbackState === PlaybackState.Paused
        ? 'orange'
        : 'label';
  const trackName = nowPlaying?.name || loadedSound || 'No sound selected';
  return (
    <Stack vertical>
      <Stack.Item>
        <Stack align="center" p={1}>
          <Stack.Item>
            <Icon
              name="compact-disc"
              size={4}
              color={nowPlaying ? stateColor : 'label'}
              spin={playbackState === PlaybackState.Playing}
            />
          </Stack.Item>
          <Stack.Item grow minWidth={0}>
            <Stack vertical>
              <Stack.Item>
                <Stack align="center" justify="space-between">
                  <Stack.Item color="label" bold>
                    {nowPlaying ? 'NOW PLAYING' : 'ON DECK'}
                  </Stack.Item>
                  <Stack.Item color={stateColor} bold>
                    <Stack align="center">
                      <Icon name={STATE_ICONS[playbackState]} />
                      <Box>{playbackState.toUpperCase()}</Box>
                    </Stack>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <Tooltip content={trackName}>
                  <Box bold overflow="hidden" nowrap>
                    {trackName}
                  </Box>
                </Tooltip>
              </Stack.Item>
              <Stack.Item>
                <Stack align="baseline">
                  <Stack.Item>
                    {formatTime(
                      (nowPlaying?.elapsed || 0) * DECISECONDS_PER_SECOND,
                    )}
                  </Stack.Item>
                  {nowPlaying && (
                    <Stack.Item color="label">
                      {nowPlaying.duration
                        ? `/ ${formatTime(
                            nowPlaying.duration * DECISECONDS_PER_SECOND,
                          )}`
                        : '/ Duration unknown'}
                    </Stack.Item>
                  )}
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <PlaybackProgress track={nowPlaying} />
      </Stack.Item>
    </Stack>
  );
};

const PlaybackProgress = ({ track }: { track: PlayingTrack | null }) => {
  const { duration = 0, elapsed = 0, paused = false } = track || {};
  const remaining = Math.max(0, duration - elapsed);
  return (
    <ProgressBar
      value={duration ? elapsed : 0}
      maxValue={duration || 1}
      color={!track ? 'label' : paused ? 'orange' : 'blue'}
    >
      {!track
        ? 'No track playing'
        : duration
          ? `${formatTime(remaining * DECISECONDS_PER_SECOND)} remaining`
          : 'Duration unknown'}
    </ProgressBar>
  );
};
