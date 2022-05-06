/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

export interface WeaponVendorData {
  credits: {
    sidearm: number;
    loadout: number;
    utility: number;
    ammo: number;
    assistant: number;
  };
  stock: WeaponVendorStockData[];
}

export interface WeaponVendorStockData {
  ref: string;
  name: string;
  description: string;
  cost: number;
  category: string;
}
