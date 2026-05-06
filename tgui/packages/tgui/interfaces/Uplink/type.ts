/**
 * @file
 * @copyright 2024
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { BooleanLike } from 'tgui-core/react';

export interface UplinkData {
  item_entries: Record<string, ItemData[]>;
  currency_amount: number;
  currency_name: string;
  title: string;
  theme: string;
  vr: BooleanLike;
}

export interface ItemData {
  name: string;
  desc: string;
  cost: number;
  cooldown: number | null;
  vr_allowed: BooleanLike;
  icon: string | null;
}

export interface EnvironmentProps {
  isVr: boolean;
  currency_amount: number;
  currency_name: string;
}
