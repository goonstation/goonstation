import { BooleanLike } from "common/react";

export interface ClothingBoothData {
  catalogue: Record<string, ClothingBoothGroupingData>;
  money?: number;
  name: string;
  previewHeight: number;
  previewIcon: string;
  previewShowClothing: BooleanLike;
  selectedGroupingName: string | null;
  selectedItemName: string | null;
}

export interface ClothingBoothGroupingData {
  name: string;
  list_icon: string;
  cost_min: number;
  cost_max: number;
  clothingbooth_items: Record<string, ClothingBoothItemData>;
  grouping_tags: Record<string, ClothingBoothGroupingTagsData>;
  slot: ClothingBoothSlotKey;
}

export interface ClothingBoothItemData {
  name: string;
  cost: number;
  swatch_background_colour?: string;
	// swatch_foreground_shape = null TODO: shapes
	/** This will be the colour of the `swatch_foreground_shape` specified.
   * Manually override if a `swatch_foreground_shape` is defined. */
	// var/swatch_foreground_colour = "#000000"
}

export interface ClothingBoothGroupingTagsData {
  name: string;
  colour?: string;
  display_order: number;
}

// keep in sync with \_std\defines\clothing.dm SLOT_ defines
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
  Ordinal = "Ordinal",
}

export enum ClothingBoothSortComparatorType {
  String,
  Number,
}
