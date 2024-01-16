import { BooleanLike } from "common/react";

export interface ClothingBoothData {
  catalogue: ClothingBoothGroupingData[]
  money?: number;
  name: string;
  previewHeight: number; // TODO: do we need this?
  previewIcon: string;
  previewShowClothing: BooleanLike;
  selectedGroupingId: string | null; // TODO
  selectedItemId: string | null; // TODO
}

export interface ClothingBoothGroupingData {
  name: string;
  list_icon: string;
  cost_min: number;
  cost_max: number;
  clothingbooth_items: ClothingBoothItemData[]
  slot: ClothingBoothSlotKey;
  // TODO: tags?
}

interface ClothingBoothItemData {
  name: string;
  cost: number;
  swatch_background_colour?: string;
	// swatch_foreground_shape = null TODO: shapes
	/** This will be the colour of the `swatch_foreground_shape` specified.
   * Manually override if a `swatch_foreground_shape` is defined. */
	// var/swatch_foreground_colour = "#000000"
}

export enum ClothingBoothSlotKey {
  Mask = 2,
  Glasses = 9,
  Gloves = 10,
  Headwear = 11,
  Shoes = 12,
  Suit = 13,
  Uniform = 14,
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
