/**
 * @file
 * @copyright 2026
 * @author DisturbHerb (https://github.com/DisturbHerb)
 * @license ISC
 */

export interface ForcedAssignmentPanelData {
  currentState: number;
  forcedAssignments: Record<string, ForcedAssignment>;
}

export interface ForcedAssignment {
  ckey: string;
  playerName: string;
  forcedJobInput: string;
  forcedJob: string;
  forcedAntagInput: Array<string>;
  forcedAntags: Record<string, ForcedAntagonist>;
}

export interface ForcedAntagonist {
  antagonistPath: string;
  displayName: string;
  doEquipment: string;
  doObjectives: string;
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
