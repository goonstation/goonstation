import { BooleanLike } from "common/react";

export interface ClothingBoothData {
  catalogue: Record<string, ClothingBoothGroupingData>;
  scannedID?: string;
  accountBalance?: number;
  cash?: number;
  name: string;
  previewHeight: number;
  previewIcon: string;
  previewShowClothing: BooleanLike;
  selectedGroupingName: string | null;
  selectedItemName: string | null;
  tags: Record<string, ClothingBoothGroupingTagsData>;
}

export interface ClothingBoothGroupingData {
  name: string;
  list_icon: string;
  cost_min: number;
  cost_max: number;
  clothingbooth_items: Record<string, ClothingBoothItemData>;
  grouping_tags: string[];
  slot: ClothingBoothSlotKey;
}

export interface ClothingBoothItemData {
  name: string;
  cost: number;
  swatch_background_colour?: string;
	swatch_foreground_shape?: string;
	swatch_foreground_colour?: string;
}

export interface ClothingBoothGroupingTagsData {
  name: string;
  colour?: string;
  display_order?: number | 1;
}

// Keep in sync with `\_std\defines\clothing.dm` `SLOT_` defines.
export enum ClothingBoothSlotKey {
  Mask = "wear_mask",
  Glasses = "glasses",
  Gloves = "gloves",
  Headwear = "head",
  Shoes = "shoes",
  Suit = "wear_suit",
  Uniform = "w_uniform",
}

export enum ClothingBoothSortType {
  Name = "Name",
  Price = "Price",
  Variants = "Variants",
}

export enum ClothingBoothSortComparatorType {
  String,
  Number,
}

export enum TagDisplayOrderType {
  Season = 1,
  Formality = 2,
  Collection = 3,
}
