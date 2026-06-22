/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */

import { BooleanLike } from 'common/react';

import { CommodityData } from '../Trader/type';

export interface SupplyConsoleData {
  shipping_budget: number;
  market_reset_timer: number;
  signal_loss: number;
  requests: SupplyRequestData[];
  order_history: OrderHistoryData[];
  supply_categories: string[];
  supply_entries: SupplyEntryData[];
  market_data: MarketEntryData[];
  trader_data: SupplyTraderData[];
}

interface SupplyRequestData {
  supply_name: string;
  order_ref: string;
  requester: string;
  cost: number;
  console_location: string;
}

interface SupplyEntryData {
  name: string;
  desc: string;
  category: string;
  cost: number;
  ref: string;
}

interface OrderHistoryData {
  supply_name: string;
  orderer: string;
  cost: number;
  comment: string;
}

interface MarketEntryData {
  name: string;
  in_demand: BooleanLike;
  price: number;
}

// CommodityData reused from interfaces/Trader/type.ts
interface SupplyTraderData {
  name: string;
  ref: string;
  picture: string;
  goods_sell: CommodityData[];
  goods_buy: CommodityData[];
  cart: CommodityData[];
}

export enum SupplyConsoleTabKeys {
  Requests,
  Supplies,
  History,
  Market,
  Traders,
  Requisitions,
  Rockbox,
}
