/**
 * @file
 * @copyright 2022
 * @author Lynncubus (https://github.com/Lynncubus)
 * @license MIT
 */

import { BooleanLike } from 'tgui-core/react';

export type HumanInventoryData = {
  name: string;

  slots: HumanInventorySlot[];

  handcuffed: BooleanLike;
  internal: BooleanLike;
  canSetInternal: BooleanLike;
};

export type HumanInventorySlot = {
  id: string;
  item?: string;
};
