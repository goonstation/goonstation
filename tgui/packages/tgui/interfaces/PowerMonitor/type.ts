/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { BooleanLike } from '../../../common/react';
import { numericCompare, stringCompare } from '../common/sorting';

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

export const apcHeaderConfig = [{
  children: "Area",
  sortable: true,
  searchable: true,
  compareFunc: (a, b) => stringCompare(a as string, b as string),
  toString: (str) => str as string,
}, {
  children: "Eqp.",
  sortable: true,
  searchable: false,
  compareFunc: numericCompare,
}, {
  children: "Lgt.",
  sortable: true,
  searchable: false,
  compareFunc: numericCompare,
}, {
  children: "Env.",
  sortable: true,
  searchable: false,
  compareFunc: numericCompare,
}, {
  children: "Load",
  sortable: true,
  searchable: false,
  compareFunc: numericCompare,
}, {
  children: "Cell Charge",
  sortable: true,
  searchable: false,
  compareFunc: numericCompare,
}, {
  children: "Cell State",
  sortable: true,
  searchable: false,
  compareFunc: numericCompare,
}];


export const smesHeaderConfig = [{
  children: "Area",
  sortable: true,
  searchable: true,
  compareFunc: (a, b) => stringCompare(a as string, b as string),
  toString: (str) => str as string,
}, {
  children: "Stored Power#",
  sortable: true,
  searchable: false,
  compareFunc: numericCompare,
}, {
  children: "Charging",
  sortable: true,
  searchable: false,
  compareFunc: numericCompare,
}, {
  children: "Input",
  sortable: true,
  searchable: false,
  compareFunc: numericCompare,
}, {
  children: "Output",
  sortable: true,
  searchable: false,
  compareFunc: numericCompare,
}, {
  children: "Active",
  sortable: true,
  searchable: false,
  compareFunc: numericCompare,
}, {
  children: "Load",
  sortable: true,
  searchable: false,
  compareFunc: numericCompare,
}];
