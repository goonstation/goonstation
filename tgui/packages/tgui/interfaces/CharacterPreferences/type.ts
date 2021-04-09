export interface CharacterPreferencesData {
  isMentor: number;

  profiles: CharacterPreferencesProfile[];

  cloudSaves?: {
    name: string;
  }[];

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
  randomAppearance: number;

  fontSize: string;
  seeMentorPms: string;
  listenOoc: string;
  listenLooc: string;
  flyingChatHidden: string;
  autoCapitalization: string;
  localDeadchat: string;
  targetingCursor: string;
  hudTheme: string;
  tooltipOption: CharacterPreferencesTooltip;
  tguiFancy: string;
  tguiLock: string;
  viewChangelog: string;
  viewScore: string;
  viewTickets: string;
  useClickBuffer: string;
  useWasd: string;
  useAzerty: string;
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
