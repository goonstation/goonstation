/**
 * @file
 * @copyright 2022
 * @author Original Amylizzle (https://github.com/amylizzle)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import type { BooleanLike } from 'tgui-core/react';

export enum PlantmasterTab {
  Overview = 'overview',
  Extractables = 'extractables',
  SeedList = 'seedlist',
}

type DominantDataTuple<T, TDominant extends BooleanLike = BooleanLike> = [
  T,
  TDominant,
];

interface CommonItemData {
  name: DominantDataTuple<string, 0>;
  species: DominantDataTuple<string>;
  genome: DominantDataTuple<number, 0>;
  generation: DominantDataTuple<number, 0>;
  growtime: DominantDataTuple<number>;
  harvesttime: DominantDataTuple<number>;
  lifespan: DominantDataTuple<number>;
  cropsize: DominantDataTuple<number>;
  potency: DominantDataTuple<number>;
  endurance: DominantDataTuple<number>;
  charges: DominantDataTuple<number, 0>;
  item_ref: string;
}

interface SeedData extends CommonItemData {
  damage: DominantDataTuple<number, 0>;
  splicing: DominantDataTuple<'splicing'>;
}

export const isSeedData = (data: CommonItemData): data is SeedData =>
  'damage' in data;

export interface ExtractableData extends CommonItemData {}

interface CommonViewData {
  category: PlantmasterTab;
  inserted;
  inserted_container;
  num_extractables: number;
  num_seeds: number;
  output_externally: BooleanLike;
  splice_chance: number;
  show_splicing;
  splice_seeds: [SeedData, SeedData];
  sortBy: string | null;
  sortAsc: BooleanLike;
  allow_infusion: BooleanLike;
}

export interface SeedsViewData extends CommonViewData {
  category: PlantmasterTab.SeedList;
  seeds: SeedData[];
}

export interface ExtractablesViewData extends CommonViewData {
  category: PlantmasterTab.Extractables;
  extractables: ExtractableData[];
}

export interface OverviewViewData extends CommonViewData {
  category: PlantmasterTab.Overview;
}

export type PlantmasterData =
  | OverviewViewData
  | SeedsViewData
  | ExtractablesViewData;
