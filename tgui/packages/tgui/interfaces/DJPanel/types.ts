/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import type { BooleanLike } from 'tgui-core/react';

export type PreloadState = 'none' | 'requested';

export interface LibrarySound {
  name: string;
  sizeBytes: number | null;
  preloadState: PreloadState;
}

export interface PlayingTrack {
  name: string;
  channel: number;
  paused: BooleanLike;
  elapsed: number;
  duration: number;
}

export interface DJPanelData {
  announceMode: BooleanLike;
  isAdmin: BooleanLike;
  soundsEnabled: BooleanLike;
  loadedSound: string;
  frequency: number;
  sounds: LibrarySound[];
  volume: number;
  looping: BooleanLike;
  nowPlaying: PlayingTrack | null;
}
