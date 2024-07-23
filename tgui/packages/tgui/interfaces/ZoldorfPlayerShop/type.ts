/**
 * @file
 * @copyright 2024
 * @author Glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { BooleanLike } from 'tgui-core/react';

export interface ZoldorfCommonProductData {
  name: string;
  stock: number;
  infinite: BooleanLike;
  img: string;
}

export interface ZoldorfSoulProductData extends ZoldorfCommonProductData {
  soul_percentage: number;
}

export interface ZoldorfCreditProductData extends ZoldorfCommonProductData {
  price: number;
}

export type ZoldorfProductData =
  | ZoldorfSoulProductData
  | ZoldorfCreditProductData;

export const isSoulProductData = (
  value: ZoldorfProductData,
): value is ZoldorfSoulProductData => 'soul_percentage' in value;

export interface ZoldorfPlayerShopData {
  products: ZoldorfProductData[];
  credits: number;
  user_soul: number;
}
