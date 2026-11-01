/**
 * @file
 * @copyright 2023
 * @author Original Valtsu0 (https://github.com/Valtsu0)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { BooleanLike } from 'common/react';

export interface TeleConsoleData {
  xTarget: number;
  yTarget: number;
  zTarget: number;
  hostId: string;
  readout: string;
  isPanelOpen: BooleanLike;
  padNum: number;
  maxBookmarks: number;
  bookmarks: BookmarkData[];
  destinations: LongRangeData[];
  disk: BooleanLike;
}

export interface LongRangeData {
  nameRef: string;
  name: string;
}

export interface BookmarkData {
  nameRef: string;
  name: string;
  x: number;
  y: number;
  z: number;
}
