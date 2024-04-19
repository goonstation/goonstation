/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { BooleanLike } from "common/react";

export type ManufacturerData = {
  all_categories:string[];

  card_owner:string;
  error:string;
  fabricator_name:string;
  mode:string;
  rockbox_message:string;

  available_blueprints:Record<string, Manufacturable[]>;
  downloaded_blueprints:Record<string, Manufacturable[]>;
  recipe_blueprints:Record<string, Manufacturable[]>;
  hidden_blueprints:Record<string, Manufacturable[]>;

  delete_allowed:BooleanLike;
  hacked:BooleanLike;
  malfunction:BooleanLike;
  panel_open:BooleanLike;
  repeat:BooleanLike;

  card_balance:number;
  progress_pct:number;
  speed:number;
  manudrive_uses_left:number;
  min_speed:number;
  max_speed_normal:number;
  max_speed_hacked:number;
  wire_bitflags:number;

  manudrive:Manudrive;
  indicators:WireIndicators;

  resource_data:Resource[];
  rockboxes:Rockbox[];
  queue:QueueBlueprint[];
  wires:number[];
}

export type Manudrive = {
  name:string;
  limit:number;
}

// Keyed by name
export type Manufacturable = {
  name:string

  material_names:string[];
  item_paths:string[];
  item_names:string[];
  item_amounts:string[];
  item_descriptions:string[];

  create:number;
  time:number;

  category:string;
  byondRef:string;
  img:string

  show_cost:BooleanLike;
}

export type Rockbox = {
  name: string;
  area_name: string;
  byondRef: string;
  ores: Ore[];
}

export type Resource = {
  name: string;
  id: string;
  amount: number;
  satisfies: string[];
}

export type Ore = {
  name: string;
  amount: number;
  cost: number;
}

export type MaintenancePanel = {
  indicators: WireIndicators;
  wires: number[];
  wire_bitflags:number;
}

export type WireIndicatorsData = {
  electrified: number;
  malfunctioning: BooleanLike;
  hacked: BooleanLike;
  hasPower: BooleanLike;
}

export type WireData = {
  colorName: string;
  colorid: string;
  flag: number;
  id: number;
}

export type QueueBlueprint = {
  name: string;
  category: string;
  type: 'available' | 'hidden' | 'download' | 'drive_blueprint';
}
