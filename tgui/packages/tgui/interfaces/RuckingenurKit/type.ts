/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license MIT
 */

import { BooleanLike } from 'tgui-core/react';

export interface RuckingenurKitData {
  hide_allowed: BooleanLike;
  scanned_items: Array<ScannedItemData>;
  legacyElectronicFrameMode: BooleanLike;
}

export interface ScannedItemData {
  name: string;
  description: string;
  has_item_mats: BooleanLike;
  blueprint_available: BooleanLike;
  locked: BooleanLike;
  imagePath: string | null;
  ref: string;
}
