/**
 * @file
 * @copyright 2021
 * @author Zonespace (https://github.com/Zonespace27)
 * @license MIT
 */

export interface ComUplinkData {
  points: number;
  stock: ComUplinkStockData[];
  types: {
    Commander1: number;
    Commander2: number;
  };
}

export interface ComUplinkStockData {
  ref: string;
  name: string;
  description: string;
  cost: number;
  category: string;
}
