/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { ReactNode } from 'react';

import { SortDirection } from './constant';

export interface Column<Row extends object, Value> {
  field?: keyof Row;
  id: string;
  name: string;
  sorter?: (a: Value, b: Value) => number;
  template?: (config: CellTemplateConfig<Row, Value>) => ReactNode;
  valueSelector?: (config: CellValueSelectorConfig<Row, Value>) => Value;
}

export interface CellTemplateConfig<Row extends object, Value> {
  act: (action: string, payload?: object) => void;
  column: Column<Row, Value>;
  row: Row;
  value: Value;
}

export interface CellValueSelectorConfig<Row extends object, Value> {
  column: Column<Row, Value>;
  row: Row;
}

export interface SorterConfig<Row extends object, Value> {
  row: Row;
  value: Value;
}

export interface SortConfig {
  dir: SortDirection;
  id: string;
}

export interface PlayerData {
  assignedRole: string;
  computerId: string;
  ckey: string;
  ip: string;
  joined: string;
  mobRef: string;
  name: string;
  playerLocation: string;
  playerType: string;
  realName: string;
  specialRole: string;
  ping: number;
}

export interface PlayerPanelData {
  players: {
    [ckey: string]: PlayerData;
  };
}
