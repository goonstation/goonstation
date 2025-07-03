/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { BooleanLike } from 'tgui-core/react';

export interface CharacterPreferencesData {
  isMentor: BooleanLike;

  profiles: CharacterPreferencesProfile[];

  cloudSaves?: string[];

  preview: string;
  profileName: string;
  profileModified: number;
  nameFirst: string;
  nameMiddle: string;
  nameLast: string;
  hyphenateName: BooleanLike;
  robotName: string;
  randomName: number;
  gender: string;
  pronouns: string;
  age: string;
  bloodRandom: string;
  bloodType: string;
  pin: string;
  flavorText: string;
  securityNote: string;
  medicalNote: string;
  syndintNote: string;
  fartsound: string;
  screamsound: string;
  chatsound: string;
  pdaColor: string;
  pdaRingtone: string;
  skinTone: string;
  specialStyle: string;
  eyeColor: string;
  customColor1: string;
  customStyle1: string;
  customColor2: string;
  customStyle2: string;
  customColor3: string;
  customStyle3: string;
  underwearColor: string;
  underwearStyle: string;
  randomAppearance: BooleanLike;

  fontSize: string;
  seeMentorPms: BooleanLike;
  listenOoc: BooleanLike;
  listenLooc: BooleanLike;
  flyingChatHidden: BooleanLike;
  autoCapitalization: BooleanLike;
  localDeadchat: BooleanLike;
  targetingCursor: string;
  targetingCursorPreview: string;
  hudTheme: string;
  hudThemePreview: string;
  tooltipOption: CharacterPreferencesTooltip;
  scrollWheelTargeting: CharacterPreferencesScrollTarget;
  tguiFancy: BooleanLike;
  tguiLock: BooleanLike;
  viewChangelog: BooleanLike;
  viewScore: BooleanLike;
  viewTickets: BooleanLike;
  useClickBuffer: BooleanLike;
  helpTextInExamine: BooleanLike;
  useWasd: BooleanLike;
  useAzerty: BooleanLike;
  preferredMap: string;
  traitsData: Record<string, CharacterPreferencesTraitStaticData>;
  traitsAvailable: CharacterPreferencesTraitData[];
  traitsMax: number;
  traitsPointsTotal: number;
  partsData: Partial<Record<string, CharacterPreferencesPartData>>;
}
export interface CharacterPreferencesPartData {
  id: string;
  name: string;
  points: number;
  img: string;
}

export interface CharacterPreferencesTraitStaticData {
  id: string;
  name: string;
  desc: string;
  category?: string[];
  img: string;
  points: number;
}

export interface CharacterPreferencesTraitData {
  id: string;
  selected?: BooleanLike;
  available: BooleanLike;
}

export type CharacterPreferencesTrait = CharacterPreferencesTraitData &
  CharacterPreferencesTraitStaticData;

export interface CharacterPreferencesProfile {
  active: boolean;
  name: string;
}

export enum CharacterPreferencesTabKeys {
  Saves,
  General,
  Character,
  Traits,
  GameSettings,
}

export enum CharacterPreferencesTooltip {
  Always = 1, // TOOLTIP_ALWAYS
  Never = 2, // TOOLTIP_NEVER
  Alt = 3, // TOOLTIP_ALT
}

export enum CharacterPreferencesScrollTarget {
  Never = 1, // SCROLL_TARGET_NEVER
  Hover = 2, // SCROLL_TARGET_HOVER
  Always = 3, // SCROLL_TARGET_ALWAYS
}
