/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { BooleanLike } from '../../../common/react';
import { SortDirection } from '../common/sorting/constant';

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
  apcNames: Record<string, string>;
  history: [available: number, load: number][];
}

/**
 * Indexed array to lower data transfer between byond and the window.
 */
export type PowerMonitorApcItemData = [
  ref: string,
  equipment: number,
  lighting: number,
  environment: number,
  load: number,
  cellCharge?: number,
  cellCharging?: number
];

export interface PowerMonitorSmesData extends PowerMonitorData {
  type: PowerMonitorType.Smes;
  available: number;
  load: number;
  units: PowerMonitorSmesItemData[];
  unitNames: Record<string, string>;
  history: [available: number, load: number][];
}

/**
 * Indexed array to lower data transfer between byond and the window.
 */
export type PowerMonitorSmesItemData = [
  ref: string,
  stored: number,
  charging: BooleanLike,
  input: number,
  output: number,
  online: BooleanLike,
  load?: number
];

export interface PowerMonitorSmesStaticItemData {
  name: string;
}

export const isDataForApc = (data: PowerMonitorData): data is PowerMonitorApcData => data.type === PowerMonitorType.Apc;
export const isDataForSmes = (data: PowerMonitorData): data is PowerMonitorSmesData =>
  data.type === PowerMonitorType.Smes;

export enum ApcTableHeaderColumns {
  Area = 0,
  Equipment = 1,
  Lighting = 2,
  Environment = 3,
  Load = 4,
  CellCharge = 5,
  CellState = 6
}

export type ApcTableHeaderColumnSortState = {
  dir: SortDirection,
  field: ApcTableHeaderColumns
}

export enum SmesTableHeaderColumns {
  Area = 0,
  StoredPower = 1,
  Charging = 2,
  Input = 3,
  Output = 4,
  Active = 5,
  Load = 6
}

export type SmesTableHeaderColumnSortState = {
  dir: SortDirection,
  field: SmesTableHeaderColumns
}

export const numericCompare = (a: number, b: number): number => {

  if (a === b) {
    return 0;
  } else if (a > b) {
    return 1;
  } else {
    return -1;
  }

};
