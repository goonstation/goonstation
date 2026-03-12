import type { BooleanLike } from 'tgui-core/react';

export interface RoboticsControlData {
  user_is_ai: BooleanLike;
  user_is_cyborg: BooleanLike;
  ais: AIData[];
  cyborgs: CyborgData[];
  ghostdrones: GhostdroneData[];
}

export interface AIData {
  name: string;
  mob_ref: string;
  status: Status;
  killswitch_time: number | null;
}

export interface CyborgData {
  name: string;
  mob_ref: string;
  status: Status;
  cell_charge: number | null;
  cell_maxcharge: number | null;
  missing_brain: BooleanLike;
  module: string | null;
  lock_time: number | null;
  killswitch_time: number | null;
}

export interface GhostdroneData {
  name: string;
  mob_ref: string;
}

// mirrors STAT_ALIVE etc. defines
export enum Status {
  Alive = 0,
  Unconscious = 1,
  Dead = 2,
}
