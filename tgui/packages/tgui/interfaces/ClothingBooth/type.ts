import { BooleanLike } from "common/react";

export type GroupingId = string;
export type ItemId = string;

export interface ClothingBoothData {
  itemLookup: Record<ItemId, ClothingBoothItemData>;
  itemGroupings: ClothingBoothGroupingData[]
  money?: number;
  name: string;
  previewHeight: number; // TODO: do we need this?
  previewIcon64: string;
  previewShowClothing: BooleanLike;
  selectedGroupingId: string | null;
  selectedItemId: string | null;
}

// TODO: groups
export interface ClothingBoothGroupingData {
  id: GroupingId;
  name: string;
  ordinal?: number; // TODO: make sure some things use this maybe?
  icon_64: string;
  lowerName: string;
  costRange: number | [number, number];
  members: ClothingBoothGroupMemberData[]
  slot: ClothingBoothSlotKey;
}

interface ClothingBoothGroupMemberData {
  item_id: ItemId;
  name?: string;
  // TODO: group member display information, see below
}
/*
export interface ItemVariantProps {
  variantName: string;
  variantBackgroundColor: Color;
  variantForegroundShape: string;
  variantForegroundColor: Color;
  cost: number;
  itemPath: string;
}
*/

export interface ClothingBoothItemData {
  id: string;
  cost: number;
  name: string;
  slot: ClothingBoothSlotKey;
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
