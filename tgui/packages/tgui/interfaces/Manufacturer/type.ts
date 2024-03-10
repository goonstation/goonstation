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

  available_blueprints:Record<string, Manufacturable[]>;
  downloaded_blueprints:Record<string, Manufacturable[]>;
  drive_recipe_blueprints:Record<string, Manufacturable[]>;
  hidden_blueprints:Record<string, Manufacturable[]>;

  resource_data:Resource[];
  wires:WireData[];

  delete_allowed:BooleanLike;
  hacked:BooleanLike;
  malfunction:BooleanLike;
  panel_open:BooleanLike;
  repeat:BooleanLike;

  card_balance:number;
  speed:number;
  wire_bitflags:number;

  indicators:WireIndicators;
  rockboxes:Rockbox[];
}

// Keyed by name
export type Manufacturable = {
  item_names:string[];
  item_amounts:string[];
  create:number;
  time:number;
  category:string;
  byondRef:string;
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
