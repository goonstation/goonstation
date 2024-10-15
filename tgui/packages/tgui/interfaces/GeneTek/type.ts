import { BooleanLike } from 'tgui-core/react';

export interface GeneTekData {
  haveScanner: BooleanLike;
  materialCur: number;
  mutationsResearched: number;
  autoDecryptors: number;
  budget: number;
  costPerMaterial: number;
  researchCost: number;
  toSplice: string;
  activeGene: string;
  scannerAlert: string | null;
  scannerError: BooleanLike;
  availableResearch: ResearchEntry[][];
  finishedResearch: ResearchEntry[][];
  currentResearch: ResearchEntry[];
  equipmentCooldown: EquipmentCooldown[];
  samples: Sample[];
  savedMutations: BioEffect[];
  savedChromosomes: Chromosome[];
  combining: Ref[];
  unlock: null | UnlockStatus;
  allowed: 0 | 1 | 2;
  record: SubjectRecord;
  subject: Subject | null;
  modifyAppearance: ModifyAppearance | null;

  // Static Data
  research: Record<Ref, ResearchEntry>;
  boothCost: number;
  injectorCost: number;
  saveSlots: number;
  precisionEmitter: BooleanLike;
  materialMax: number;
  mutantRaces: MutantRace[];
  bioEffects: BioEffect[];
}

interface ResearchEntry {
  ref: Ref;
  name: string;
  desc: string;
  cost?: number;
  time?: number;
  current?: number;
  total?: number;
}

interface EquipmentCooldown {
  label: string;
  cooldown: number;
}

interface MutantRace {
  name: string;
  icon: string;
  ref: Ref;
}

interface BioEffect {
  ref: Ref;
  name: string;
  research: ResearchLevel;
  // Full Data
  desc: string;
  icon: string;
  time: number;
  canResearch: BooleanLike;
  canInject: BooleanLike;
  canScramble: BooleanLike;
  canReclaim: BooleanLike;
  spliceError: string | null;
  dna: BioEffectDNA[];
}

export interface BioEffectDNA {
  pair: string;
  style: string;
  marker: string;
}

// See: defines/bioeffect.dm
enum ResearchLevel {
  NONE = 0,
  IN_PROGRESS = 1,
  DONE = 2,
  ACTIVATED = 3,
}

interface Sample {
  ref: Ref;
  name: string;
  uid: string;
}

interface UnlockStatus {
  length: number;
  chars: string[];
  correctChar: number | string;
  correctPos: number | string;
  tries: number;
}

interface Chromosome {
  ref: Ref;
  name: string;
  desc: string;
}

interface SubjectRecord {
  ref: Ref;
  name: string;
  uid: string;
  genes: BioEffect[];
}

interface Subject {
  preview: string | null;
  name: string;
  stat: Stat;
  health: number;
  stability: number;
  human: BooleanLike;
  bloodType: string;
  age: number;
  mutantRace: string;
  canAppearance: BooleanLike;
  premature: BooleanLike;
  potential: BioEffect[];
  active: BioEffect[];
}

enum Stat {
  Alive = 0,
  Unconscious = 1,
  Dead = 2,
}

interface ModifyAppearance {
  preview: string;
  hairStyles: string[];
  direction: number;
  skin: string;
  eyes: string;
  color1: string;
  color2: string;
  color3: string;
  style1: string;
  style2: string;
  style3: string;
  fixColors: BooleanLike;
  hasEyes: BooleanLike;
  hasSkin: BooleanLike;
  hasHair: BooleanLike;
  channels: string[];
}

type Ref = string;
