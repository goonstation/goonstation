/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import type { BooleanLike } from 'tgui-core/react';

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
  useSatchel: BooleanLike;
  preferredUplink: string;
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

  jobStaticData: Record<string, JobStaticData>;
  jobFavourite: string;
  jobsMedPriority: string[];
  jobsLowPriority: string[];
  jobsUnwanted: string[];

  antagonistStaticData: Record<string, AntagonistStaticData>;
  antagonistPreferences: Record<string, boolean>;

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
  middleMouseSwap: BooleanLike;
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

export interface JobStaticData {
  colour: string;
  disabled: BooleanLike;
  disabled_tooltip?: string;
  required: BooleanLike;
  wiki_link?: string;
}

export interface AntagonistStaticData {
  name: string;
  variable: string;
  disabled: number;
  disabled_tooltip?: string;
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
  Occupation,
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

export enum PriorityLevel {
  Favorite = 1,
  Medium = 2,
  Low = 3,
  Unwanted = 4,
}

export interface OccupationPriorityModalOptions {
  occupation: string;
  hasWikiLink: boolean;
  priorityLevel: number;
  required: boolean;
}

export interface ModalContextValue {
  setOccupationPriorityModalOptions: (
    options: OccupationPriorityModalOptions | undefined,
  ) => void;
  showResetOccupationPreferencesModal: (show: boolean | undefined) => void;
}

export interface ModalContextState {
  occupationModal: OccupationPriorityModalOptions | undefined;
  resetOccupationPreferencesModal: boolean | undefined;
}
