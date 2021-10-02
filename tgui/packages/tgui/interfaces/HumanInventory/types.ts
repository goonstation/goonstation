import { BooleanLike } from 'common/react';

export type HumanInventoryData = {
  name: string;

  slots: HumanInventorySlots;

  handcuffed: BooleanLike;
  internal: BooleanLike;
  canSetInternal: BooleanLike;
};

export type HumanInventorySlots = {
  head: HumanInventorySlot;
};

export type HumanInventorySlot = {
  slot: number;
  item?: string;
};
