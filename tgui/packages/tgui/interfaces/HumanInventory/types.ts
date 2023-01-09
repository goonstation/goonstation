import { BooleanLike } from 'common/react';

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
  obstructed: BooleanLike;
};
