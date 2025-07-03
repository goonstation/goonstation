/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { BooleanLike } from 'tgui-core/react';

export interface DoorTimerData {
  maxTime: number;

  timing: BooleanLike;
  time: number;
  flasher?: BooleanLike;
  recharging?: BooleanLike;
  flusher?: BooleanLike;
  flusheropen?: BooleanLike;
  opening?: BooleanLike;
}
