/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { BooleanLike } from 'common/react';

export interface ClothingBoothData {
  accountBalance?: number;
  cash?: number;
  catalogue: Record<string, ClothingBoothGroupingData>;
  everythingIsFree: BooleanLike;
  name: string;
  previewHeight: number;
  previewIcon: string;
  previewShowClothing: BooleanLike;
  scannedID?: string;
  selectedGroupingName: string | null;
  selectedItemName: string | null;
  tags: Record<string, ClothingBoothGroupingTagsData>;
}

export interface ClothingBoothGroupingData {
  clothingbooth_items: Record<string, ClothingBoothItemData>;
  cost_max: number;
  cost_min: number;
  grouping_tags: string[];
  list_icon: string;
  name: string;
  slot: ClothingBoothSlotKey;
}

export interface ClothingBoothItemData {
  name: string;
  cost: number;
  swatch_background_color?: string;
  swatch_foreground_shape?: string;
  swatch_foreground_color?: string;
}

export interface SwatchForegroundProps {
  color: string;
}

export interface ClothingBoothGroupingTagsData {
  name: string;
  color?: string;
  display_order?: number;
}

// Keep in sync with `\_std\defines\clothing.dm` `SLOT_` defines.
export enum ClothingBoothSlotKey {
  Mask = 'wear_mask',
  Glasses = 'glasses',
  Gloves = 'gloves',
  Headwear = 'head',
  Shoes = 'shoes',
  Suit = 'wear_suit',
  Uniform = 'w_uniform',
}

export enum ClothingBoothSortType {
  Name = 'Name',
  Price = 'Price',
  Variants = 'Variants',
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

export type TagFilterLookup = Partial<Record<string, boolean>>;

export type SlotFilterLookup = Partial<Record<ClothingBoothSlotKey, boolean>>;
