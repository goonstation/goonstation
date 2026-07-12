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
  rockbox_transaction_percent_fee: number;
  rockbox_transaction_minimum_fee: number;
  requests: SupplyRequestData[];
  order_history: OrderHistoryData[];
  supply_categories: string[];
  supply_entries: SupplyEntryData[];
  market_data: MarketEntryData[];
  trader_data: SupplyTraderData[];
  requisition_data: RequisitionData[];
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
  current_message: string;
  patience: number;
  goods_sell: CommodityData[];
  goods_buy: CommodityData[];
  cart: CommodityData[];
  cart_count: number;
  cart_max: number;
  cart_cost: number;
}

interface RequisitionData {
  name: string;
  desc: string;
  ref: string;
  pinned: BooleanLike;
  req_code: string;
  flavor_desc: string;
  payout: number;
  item_rewards: RequisitionItemRewardData[];
  urgent: BooleanLike;
  cycles_left: number;
}
interface RequisitionItemRewardData {
  name: string;
  count: number;
}

export enum SupplyConsoleTabKeys {
  Requests,
  Supplies,
  History,
  Market,
  Traders,
  Requisitions,
}
