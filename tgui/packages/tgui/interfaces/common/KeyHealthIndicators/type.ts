import { BooleanLike } from 'tgui-core/react';

export interface EmbeddedObjects {
  foreign_object_count: number;
  implant_count: number;
  has_chest_object: BooleanLike;
}

export interface DisplayOccupiedProps {
  occupied: BooleanLike;
}

export interface DisplayTemperatureProps extends DisplayOccupiedProps {
  body_temp: number;
  optimal_temp: number;
}

export interface DisplayTempImplantRowProps extends DisplayTemperatureProps {
  embedded_objects: EmbeddedObjects;
}

export interface DisplayBloodPressureProps extends DisplayOccupiedProps {
  patient_status: number;
  blood_pressure_rendered: string;
  blood_pressure_status: string;
  blood_volume: number;
}

export interface BrainDamageData {
  value: number;
  desc: string;
  color: string;
}
