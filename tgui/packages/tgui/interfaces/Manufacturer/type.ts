/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */
import { BooleanLike } from 'common/react';

export type ManufacturerData = {
  all_categories: string[];

  card_owner: string;
  error: string;
  fabricator_name: string;
  mode: 'working' | 'halt' | 'ready';

  available_blueprints: Record<string, ManufacturableData[]>;
  downloaded_blueprints: Record<string, ManufacturableData[]>;
  recipe_blueprints: Record<string, ManufacturableData[]>;
  hidden_blueprints: Record<string, ManufacturableData[]>;

  producibility_data: Record<string, Record<string, BooleanLike>>;

  delete_allowed: BooleanLike;
  hacked: BooleanLike;
  malfunction: BooleanLike;
  panel_open: BooleanLike;
  repeat: BooleanLike;

  banking_info: BankAccount;
  progress_pct: number;
  speed: number;
  manudrive_uses_left: number;
  min_speed: number;
  max_speed_normal: number;
  max_speed_hacked: number;
  wire_bitflags: number;

  manudrive: Manudrive;
  indicators: WireIndicatorsData;

  resource_data: ResourceData[];
  rockboxes: RockboxData[];
  queue: QueueBlueprint[];
  wires: number[];
};

export type BankAccount = {
  name: string;
  current_money: number;
};

export type Manudrive = {
  name: string;
  limit: number;
};

// Keyed by name
export type ManufacturableData = {
  name: string;

  requirement_data: RequirementData[];
  item_names: string[];
  item_descriptions: string[];

  create: number;
  time: number;

  category: string;
  byondRef: string;
  img: string;

  apply_material: BooleanLike;
  show_cost: BooleanLike;
  isMechBlueprint: BooleanLike;
};

export type RequirementData = {
  name: string;
  id: string;
  amount: number;
};

export type RockboxData = {
  name: string;
  area_name: string;
  byondRef: string;
  ores: OreData[];
};

export type ResourceData = {
  name: string;
  id: string;
  byondRef: string;
  amount: number;
  satisfies: string[];
};

export type OreData = {
  name: string;
  amount: number;
  cost: number;
};

export type WireIndicatorsData = {
  electrified: number;
  malfunctioning: BooleanLike;
  hacked: BooleanLike;
  hasPower: BooleanLike;
};

export type WireData = {
  colorName: string;
  colorid: string;
  flag: number;
  id: number;
};

export type QueueBlueprint = {
  name: string;
  category: string;
  type: 'available' | 'hidden' | 'download' | 'drive_blueprint';
};
