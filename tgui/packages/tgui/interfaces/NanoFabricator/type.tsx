/**
 * Backend data types for the nanofabricator interface.
 */

export interface NanoPartData {
  amount: number;
  name: string;
  optional: boolean;
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
  complete: boolean;
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
  insufficient: boolean;
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
  outputInternal: boolean;
  partOptions: NanoPartOptionData[];
  recipes: NanoRecipeData[];
  selectedRecipe: NanoSelectedRecipeData | null;
  selectingPart: NanoSelectingPartData | null;
  storage: NanoStorageData[];
}
