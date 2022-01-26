/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

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
