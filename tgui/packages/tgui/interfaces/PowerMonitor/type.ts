import { BooleanLike } from 'common/react';

export enum PowerMonitorType {
  Apc = 'apc',
  Smes = 'smes',
}

export interface PowerMonitorData {
  type: PowerMonitorType;
}

export interface PowerMonitorApcData extends PowerMonitorData {
  type: PowerMonitorType.Apc;
  available: number;
  load: number;
  apcs: PowerMonitorApcItemData[];
  apcsStatic: Record<string, PowerMonitorApcStaticItemData>;
  history: { available: number; load: number }[];
}

export interface PowerMonitorApcItemData {
  ref: string;
  equipment: number;
  lighting: number;
  environment: number;
  load: number;
  cell?: {
    charge: number;
    charging: number;
  };
}

export interface PowerMonitorApcStaticItemData {
  name: string;
}

export interface PowerMonitorSmesData extends PowerMonitorData {
  type: PowerMonitorType.Smes;
  available: number;
  load: number;
  units: PowerMonitorSmesItemData[];
  unitsStatic: Record<string, PowerMonitorSmesStaticItemData>;
  history: { available: number; load: number }[];
}

export interface PowerMonitorSmesItemData {
  ref: string;
  stored: number;
  charging: BooleanLike;
  input: number;
  output: number;
  online: BooleanLike;
  load?: number;
}

export interface PowerMonitorSmesStaticItemData {
  name: string;
}

export const isDataForApc = (data: PowerMonitorData): data is PowerMonitorApcData => data.type === PowerMonitorType.Apc;
export const isDataForSmes = (data: PowerMonitorData): data is PowerMonitorSmesData =>
  data.type === PowerMonitorType.Smes;
