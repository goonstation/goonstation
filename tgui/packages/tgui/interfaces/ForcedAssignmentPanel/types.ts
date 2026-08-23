/**
 * @file
 * @copyright 2026
 * @author DisturbHerb (https://github.com/DisturbHerb)
 * @license ISC
 */

import { BooleanLike } from 'common/react';

export interface ForcedAssignmentPanelData {
  currentState: number;
  forcedAssignments: Record<string, ForcedAssignment>;
}

export interface ForcedAssignment {
  ckey: string;
  playerName: string;
  forcedJob: string;
  forcedAntags: Record<string, ForcedAntagonist>;
}

export interface ForcedAntagonist {
  displayName: string;
  doEquipment: BooleanLike;
  doObjectives: BooleanLike;
  customObjective: string;
}

// Keep in sync with `_std\setup.dm`.
export enum GameStates {
  GameStateInvalid = 0,
  GameStatePreMapLoad = 1,
  GameStateMapLoad = 2,
  GameStateWorldInit = 3,
  GameStateWorldNew = 4,
  GameStatePregame = 5,
  GameStateSettingUp = 6,
  GameStatePlaying = 7,
  GameStateFinished = 8,
}
