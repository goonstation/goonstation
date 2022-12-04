import { BooleanLike } from 'common/react';
export interface OperatingComputerData {
  occupied: BooleanLike

  rad_stage: string
  rad_dose: number

  patient_name: string
  patient_status: number

  body_temp: number
  optimal_temp: number

  patient_data: [
    {
      brute: [number]
      burn: [number]
      toxin: [number]
      oxygen: [number]
    }
  ]

  max_health: number
  current_health: number
  brute: number
  burn: number
  toxin: number
  oxygen: number

  blood_volume: number
  blood_pressure_status: string
  blood_pressure_rendered: string

  brain_damage_desc: string
  brain_damage_value: number

  embedded_objects: EmbeddedObjects

  organ_status: []
  limb_status: []

  age: number
  blood_type: string
  blood_color_name: string
  blood_color_value: string
  clone_generation: number
  genetic_stability: number

  cloner_defects: number
  reagent_container // ReagentContainer

}

export interface OperatingComputerDisplayTitleProps {
  occupied: BooleanLike,
  patient_name: string,
  patient_health: number,
  patient_max_health: number,
  patient_status: number,
}

export interface PatientSummaryProps {
  occupied: BooleanLike,
  patient_status: number,
  isCrit: boolean,
}

export interface DisplayKeyHealthIndicatorProps {
  occupied: BooleanLike,
  rad_stage: string,
  rad_dose: number,
  brain_damage_desc: string,
  brain_damage_value: number,
  embedded_objects: EmbeddedObjects,
}

interface EmbeddedObjects {
    foreign_object_count: number,
    implant_count: number,
    has_chest_object: BooleanLike,
}
