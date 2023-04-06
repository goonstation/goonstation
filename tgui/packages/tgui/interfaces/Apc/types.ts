/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { BooleanLike } from 'common/react';

export enum InterfaceType {
  LocalOnly = 0,
  LocalAndNetwork = 1,
  NetworkOnly = 2,
}

export type ApcAccessPanelData = Pick<ApcData, 'is_ai' | 'wiresexposed'>;
export type ApcWireCutData = Pick<ApcData, 'dark_red_cut' | 'orange_cut' | 'white_cut' | 'yellow_cut'>
export type ApcInterfaceData = Pick<ApcData, 'can_access_remotely' | 'setup_networkapc'>;

export type ApcData = {
  aidisabled: BooleanLike;
  area_name;
  area_requires_power;
  can_access_remotely: BooleanLike;
  cell_percent;
  cell_present;
  chargecount;
  chargemode;
  charging;
  coverlocked: BooleanLike;
  dark_red_cut,
  environ;
  equipment;
  host_id;
  is_ai: BooleanLike;
  is_silicon: BooleanLike;
  lastused_environ;
  lastused_equip;
  lastused_light;
  lastused_total;
  lighting;
  locked: BooleanLike;
  main_status;
  net_id;
  orange_cut,
  operating;
  setup_networkapc: InterfaceType;
  shorted;
  white_cut,
  wiresexposed;
  yellow_cut,
};
