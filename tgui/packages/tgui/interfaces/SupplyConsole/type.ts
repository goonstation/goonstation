/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */

export interface SupplyConsoleData {
  shipping_budget: number;
  market_reset_timer: number;
  requests: SupplyRequestData[];
  order_history: OrderHistoryData[];
  supply_categories: string[];
  supply_entries: SupplyEntryData[];
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

export enum SupplyConsoleTabKeys {
  Requests,
  Supplies,
  History,
  Market,
  Traders,
  Requisitions,
  Rockbox,
}
