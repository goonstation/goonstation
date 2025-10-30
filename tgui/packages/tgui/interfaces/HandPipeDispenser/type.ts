/**
 * @file
 * @copyright 2024
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @license MIT
 */

import type { BooleanLike } from 'tgui-core/react';

export type PipeData = {
  name: string;
  image: string; // base64
  cost: number;
};

export type HandPipeDispenserData = {
  atmospipes: PipeData[];
  atmosmachines: PipeData[];
  selectedimage: string; // base64 image
  destroying: BooleanLike;
  selectedcost: number;
  resources: number;
  selecteddesc: string;
  issilicon: BooleanLike;
};

export enum Tab {
  AtmosPipes = 'atmospipes',
  AtmosMachines = 'atmosmachines',
}
