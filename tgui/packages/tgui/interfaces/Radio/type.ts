import { BooleanLike } from 'common/react';

export interface RadioData {
  name: string;
  broadcasting: BooleanLike;
  listening: BooleanLike;
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
}

export enum RadioWires {
  Signal = 1,
  Receive = 2,
  Transmit = 4,
}
