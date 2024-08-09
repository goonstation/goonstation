/**
 * @file
 * @copyright 2022
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { BooleanLike } from 'tgui-core/react';

import {
  BrainDamageData,
  DisplayOccupiedProps,
  EmbeddedObjects,
} from '../common/KeyHealthIndicators/type';
export interface OperatingComputerData {
  occupied: BooleanLike;

  rad_stage: number;
  rad_dose: number;

  patient_name: string;
  patient_status: number;

  body_temp: number;
  optimal_temp: number;

  patient_data: [
    {
      brute: [number];
      burn: [number];
      toxin: [number];
      oxygen: [number];
    },
  ];

  max_health: number;
  current_health: number;
  brute: number;
  burn: number;
  toxin: number;
  oxygen: number;

  blood_volume: number;
  blood_pressure_status: string;
  blood_pressure_rendered: string;

  brain_damage: BrainDamageData;

  embedded_objects: EmbeddedObjects;

  organ_status: OrganData[];
  limb_status: LimbData[];

  age: number;
  blood_type: string;
  blood_color_name: string;
  blood_color_value: string;
  clone_generation: number;
  genetic_stability: number;
  cloner_defect_count: number;

  reagent_container; // ReagentContainer
}

export interface OrganData {
  organ: string;
  state: string;
  special: string;
  color: string;
}

export interface LimbData {
  limb: string;
  status: string;
}

export interface OperatingComputerDisplayTitleProps
  extends DisplayOccupiedProps {
  patient_name: string;
  patient_health: number;
  patient_max_health: number;
  patient_status: number;
}

export interface PatientSummaryProps extends DisplayOccupiedProps {
  patient_status: number;
  isCrit: boolean;
}

export interface DisplayBloodstreamContentProps extends DisplayOccupiedProps {
  reagent_container;
}

export interface DisplayAnatomicalAnomoliesProps extends DisplayOccupiedProps {
  organs: OrganData[];
  limbs: LimbData[];
}

export interface DisplayGeneticAnalysisProps extends DisplayOccupiedProps {
  age: number;
  blood_type: string;
  blood_color_value: string;
  blood_color_name: string;
  clone_generation: number;
  cloner_defect_count: number;
  genetic_stability: number;
}

export interface DisplayLimbsProps extends DisplayOccupiedProps {
  limbs: LimbData[];
}
export interface DisplayLimbProps {
  limb: string;
  status: string;
}

export interface DisplayOrgansProps extends DisplayOccupiedProps {
  organs: OrganData[];
}
