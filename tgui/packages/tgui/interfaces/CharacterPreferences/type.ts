import { BooleanLike } from 'common/react';

export interface CharacterPreferencesData {
  isMentor: BooleanLike;

  profiles: CharacterPreferencesProfile[];

  cloudSaves?: string[]

  preview: string;
  profileName: string;
  profileModified: number;
  nameFirst: string;
  nameMiddle: string;
  nameLast: string;
  randomName: number;
  gender: string;
  age: string;
  bloodRandom: string;
  bloodType: string;
  pin: string;
  flavorText: string;
  securityNote: string;
  medicalNote: string;
  fartsound: string;
  screamsound: string;
  chatsound: string;
  pdaColor: string;
  pdaRingtone: string;
  skinTone: string;
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
  hudTheme: string;
  tooltipOption: CharacterPreferencesTooltip;
  tguiFancy: BooleanLike;
  tguiLock: BooleanLike;
  viewChangelog: BooleanLike;
  viewScore: BooleanLike;
  viewTickets: BooleanLike;
  useClickBuffer: BooleanLike;
  useWasd: BooleanLike;
  useAzerty: BooleanLike;
  preferredMap: string;
}

export interface CharacterPreferencesProfile {
  active: boolean;
  name: string;
}

export enum CharacterPreferencesTabKeys {
  Saves,
  General,
  Character,
  GameSettings,
}

export enum CharacterPreferencesTooltip {
  Always = 1, // TOOLTIP_ALWAYS
  Never = 2, // TOOLTIP_NEVER
  Alt = 3, // TOOLTIP_ALT
}
