/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

/**
 * Backend data types for the nanofabricator interface.
 */

import type { BooleanLike } from 'tgui-core/react';

export interface NanoPartData {
  amount: number;
  name: string;
  optional: BooleanLike;
  part_name: string;
  ref: string;
}

export interface NanoRecipeData {
  category: string;
  description: string;
  img: string | null;
  name: string;
  parts: NanoPartData[];
  ref: string;
}

export interface NanoStorageData {
  amount: number;
  img: string | null;
  name: string;
  ref: string;
}

export interface NanoAssignedData {
  amount: number;
  img: string | null;
  name: string;
}

export interface NanoSelectedPartData extends NanoPartData {
  assigned: NanoAssignedData | null;
}

export interface NanoSelectedRecipeData {
  complete: BooleanLike;
  description: string;
  img: string | null;
  maxAmount: number;
  name: string;
  parts: NanoSelectedPartData[];
  ref: string;
}

export interface NanoPartOptionData {
  amount: number;
  img: string | null;
  insufficient: BooleanLike;
  name: string;
  ref: string;
}

export interface NanoSelectingPartData {
  name: string;
  part_name: string;
  ref: string;
}

export interface NanoFabricatorData {
  categories: string[];
  outputInternal: BooleanLike;
  partOptions: NanoPartOptionData[];
  recipes: NanoRecipeData[];
  selectedRecipe: NanoSelectedRecipeData | null;
  selectingPart: NanoSelectingPartData | null;
  storage: NanoStorageData[];
}
