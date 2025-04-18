/**
 * @file
 * @copyright 2022
 * @author Original Amylizzle (https://github.com/amylizzle)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import type { BooleanLike } from 'tgui-core/react';

import { ReagentContainer } from '../common/ReagentInfo';

export type PlantmasterTab = 'overview' | 'extractables' | 'seedlist';

export interface Sort {
  sortBy: string;
  sortAsc: boolean;
}

export interface SortProps {
  onSort: () => void;
  sortAsc: boolean | null;
}

type DominantDataTuple<T> = [T, BooleanLike];

interface PlantmasterItemData {
  charges: number;
  cropsize: DominantDataTuple<number>;
  endurance: DominantDataTuple<number>;
  item_ref: string;
  generation: number;
  genome: number;
  lifespan: DominantDataTuple<number>;
  harvesttime: DominantDataTuple<number>;
  growtime: DominantDataTuple<number>;
  name: string;
  potency: DominantDataTuple<number>;
  species: DominantDataTuple<string>;
}

export interface SeedData extends PlantmasterItemData {
  damage: number;
  splicing?: BooleanLike;
}

export interface ExtractableData extends PlantmasterItemData {}

interface CommonViewData {
  category: PlantmasterTab;
  inserted_desc: string;
  inserted_container: ReagentContainer | null;
  num_extractables: number;
  num_seeds: number;
  output_externally: BooleanLike;
  sortBy: string | null;
  sortAsc: BooleanLike;
  allow_infusion: BooleanLike;
}

export interface SeedsViewData extends CommonViewData {
  category: 'seedlist';
  seeds: SeedData[];
  splice_chance: number;
  splice_seeds: [SeedData | null, SeedData | null];
}

export interface ExtractablesViewData extends CommonViewData {
  category: 'extractables';
  extractables: ExtractableData[];
}

export interface OverviewViewData extends CommonViewData {
  category: 'overview';
}

export type PlantmasterData =
  | OverviewViewData
  | SeedsViewData
  | ExtractablesViewData;
