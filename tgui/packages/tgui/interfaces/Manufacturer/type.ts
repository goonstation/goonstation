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
  fabricator_name:string;
  mode:string;
  rockbox_message:string;

  available_blueprints:Record<string, Manufacturable[]>;
  downloaded_blueprints:Record<string, Manufacturable[]>;
  drive_recipe_blueprints:Record<string, Manufacturable[]>;
  hidden_blueprints:Record<string, Manufacturable[]>;

  static_available_blueprints:Record<string, Manufacturable[]>;
  static_downloaded_blueprints:Record<string, Manufacturable[]>;
  static_drive_recipe_blueprints:Record<string, Manufacturable[]>;
  static_hidden_blueprints:Record<string, Manufacturable[]>;

  delete_allowed:BooleanLike;
  hacked:BooleanLike;
  malfunction:BooleanLike;
  panel_open:BooleanLike;
  repeat:BooleanLike;

  card_balance:number;
  speed:number;
  progress_pct:number;
  wire_bitflags:number;

  indicators:WireIndicators;

  resource_data:Resource[];
  rockboxes:Rockbox[];
  queue:QueueBlueprint[];
  wires:WireData[];
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
  can_fabricate: Record<string, string> | null;
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
}

export type Ore = {
  name: string;
  amount: number;
  cost: number;
}

export type MaintenencePanel = {
  indicators: WireIndicators;
  wires: WireData[];
  wire_bitflags:number;
}

export type WireIndicators = {
  electrified: number;
  malfunctioning: BooleanLike;
  hacked: BooleanLike;
  hasPower: BooleanLike;
}

export type WireData = {
  colorName: string;
  color: string;
}

export type QueueBlueprint = {
  name: string;
  category: string;
  type: string; // "available", "hidden", "download", "drive_blueprint"
}
