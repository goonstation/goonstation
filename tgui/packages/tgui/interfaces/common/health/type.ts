/**
 * @file
 * @copyright 2026
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */
import { BooleanLike } from 'tgui-core/react';

import { ReagentContainer } from '../ReagentInfo';

export interface HealthData {
  occupied: BooleanLike;
  patient_name: string;
  patient_status: number;

  max_health: number;
  current_health: number;
  brute: number;
  burn: number;
  toxin: number;
  oxygen: number;

  // blood system may be disabled (never is in practice, but)
  blood_volume: number | null;
  bleeding: number | null;
  blood_pressure_status: string | null;
  blood_pressure_rendered: string | null;

  blood_type: string;
  blood_color_name: string;
  blood_color_value: string;

  rad_stage: number;
  rad_dose: number;

  limb_status: LimbData[];

  age: number;
  body_temp: number;
  optimal_temp: number;
  interesting: string;

  // only included with organ scan
  organ_status: OrganData[] | null;
  brain_damage: number | string | null;
  embedded_objects: EmbeddedObjects | null;

  // only included with genetic scan
  clone_generation: number | null;
  genetic_stability: number | null;
  cloner_defect_count: number | null;

  // only included with reagent scan
  reagent_container: ReagentContainer | null;

  // only included with disease scan
  disease_status: DiseaseData[] | null;
}

export interface HealthGraphData extends HealthData {
  patient_data: [
    {
      brute: number[][];
      burn: number[][];
      toxin: number[][];
      oxygen: number[][];
    },
  ];
}

export interface ImplantData {
  implant_name: string;
  implant_count: number;
}

export interface EmbeddedObjects {
  foreign_object_count: number;
  total_implant_count: number;
  implants: ImplantData[];
  has_chest_object: BooleanLike;
}

export interface DisplayOccupiedProps {
  occupied: BooleanLike;
}

export enum OrganSpecial {
  None = '',
  Missing = 'Missing',
  Cybernetic = 'Cybernetic',
  Synthetic = 'Synthetic',
  Unusual = 'Unusual',
}

export interface OrganData {
  organ_name: string;
  special: OrganSpecial;
  damage: number;
  max_health: number;
}

export enum LimbStatus {
  Missing = 'Missing',
  Okay = 'Okay',
  Cybernetic = 'Cybernetic',
  UNKNOWN = 'UNKNOWN',
}

export interface LimbData {
  limb_name: string;
  status: LimbStatus;
}

export type BrainDamage = 'Missing' | number | string | null;

export interface DiseaseData {
  scantype: string;
  state: string;
  spread: string;
  info: string;
  disease_name: string;
  stage: number;
  max_stage: number;
  cure_method: string;
}
