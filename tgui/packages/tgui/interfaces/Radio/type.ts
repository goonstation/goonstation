/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { BooleanLike } from 'tgui-core/react';

export interface RadioData {
  name: string;
  hasMicrophone: BooleanLike;
  microphoneEnabled: BooleanLike;
  hasSpeaker: BooleanLike;
  speakerEnabled: BooleanLike;
  frequency: number;
  frequencyFormatted: string;
  lockedFrequency: BooleanLike;
  secureFrequencies: {
    channel: string;
    frequency: number;
    sayToken: string;
  }[];
  wires: number;
  modifiable: BooleanLike;
  code: number;
  sendButton: BooleanLike;
  hasToggleButton: BooleanLike;
  power: BooleanLike;
}

export enum RadioWires {
  Signal = 1,
  Receive = 2,
  Transmit = 4,
}
