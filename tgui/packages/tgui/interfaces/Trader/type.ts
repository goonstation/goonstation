/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */

export interface TraderData {
  name: string;
  theme: string;
  image: string;
  currency_name: string;
  items_in_cart: number;

  accepts_card: boolean;
  available_currency: number;
  scanned_card: string;

  goods_sell: CommodityData[];
  goods_buy: CommodityData[];
}

export interface CommodityData {
  name: string;
  description: string;
  price: number;
  amount_left: number;
  ref: string;
}
