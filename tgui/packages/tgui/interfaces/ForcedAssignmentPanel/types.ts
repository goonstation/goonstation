/**
 * @file
 * @copyright 2026
 * @author DisturbHerb (https://github.com/DisturbHerb)
 * @license ISC
 */

export interface ForcedAssignmentPanelData {
  forcedAssignments: Record<string, ForcedAssignment>;
}

export interface ForcedAssignment {
  ckey: string;
  playerName: string;
  forcedJob: string;
}
