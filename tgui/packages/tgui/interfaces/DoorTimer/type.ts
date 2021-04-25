import { BooleanLike } from 'common/react';

export interface DoorTimerData {
  maxTime: number;

  timing: BooleanLike;
  time: number;
  flasher?: BooleanLike;
  recharging?: BooleanLike;
}
