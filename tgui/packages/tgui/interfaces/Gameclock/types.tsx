import { BooleanLike } from 'tgui-core/react';

export type GameClockData = {
  clockStatic: {
    name: string;
    minTime: number;
    maxTime: number;
    defaultTime: number;
  };
  timing: BooleanLike;
  turn: boolean;
  whiteTime: number;
  blackTime: number;
};
