/**
 * @file
 * @copyright 2023
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { BooleanLike } from 'tgui-core/react';

export interface AntagonistPanelData {
  tabs: AntagonistTypeTabData[];

  tabToOpenOn: string;
  currentTabSections: TabSectionData[];
  mindLocations: PositionData[];
  subordinateAntagonists: SubordinateAntagonistData[];

  gameMode: string;
  mortalityRates: MortalityRates;
}

export interface AntagonistTypeTabData {
  tabName: string;
  index: string;
}

export interface TabSectionData {
  sectionType: string;
  sectionName: string;
  sectionData: any;
}

export interface AntagonistData {
  mind_ref: string;
  antagonist_datum: string;
  real_name: string | null;
  ckey: string;
  job: string;
  dead: BooleanLike;
  has_subordinate_antagonists: BooleanLike;
}

export interface PositionData {
  area: string;
  coordinates: string;
}

export interface SubordinateAntagonistData {
  mind_ref: string;
  antagonist_datum: string;
  display_name: string | null;
  real_name: string | null;
  ckey: string;
  job: string;
  dead: BooleanLike;
}

export interface MortalityRates {
  antagonistsAlive: number;
  antagonistsDead: number;
  crewAlive: number;
  crewDead: number;
}

export interface NuclearBombData {
  nuclearBomb: string;
  maxHealth: number;
  health: number;
  timeRemaining: string;
  area: string;
  coordinates: string;
}

export interface HeadsData {
  mind_ref: string;
  role: string;
  real_name: string | null;
  ckey: string;
  dead: BooleanLike;
}

export interface GangLockerData {
  gangLocker: string;
  area: string;
  coordinates: string;
}
