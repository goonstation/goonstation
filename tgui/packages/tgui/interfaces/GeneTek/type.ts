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
  availableResearch;
  finishedResearch;

  currentResearch;
  equipmentCooldown;
  samples: Sample[];
  savedMutations;
  savedChromosomes;
  combining;
  unlock;
  allowed;
  record;
  subject;
  modifyAppearance;

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
  name: string;
  desc: string;
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
  // todo
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

type Ref = string;
