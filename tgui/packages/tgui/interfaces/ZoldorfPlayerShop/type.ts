/**
 * @file
 * @copyright 2024
 * @author Glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { BooleanLike } from "common/react";
import { InfernoNode } from "inferno";

export interface ZoldorfPlayerShopData {
  soul_products: ZoldorfSoulProductData[],
  credit_products: ZoldorfCreditProductData[],
  credits: number,
  user_soul: number,
}

export interface ZoldorfProductData {
  name: string,
  stock: number,
  infinite: BooleanLike,
  img: string,
}

export interface ZoldorfSoulProductData extends ZoldorfProductData {
  soul_percentage: number,
}

export interface ZoldorfCreditProductData extends ZoldorfProductData {
  price: number,
}

export interface ZoldorfProductListProps extends ZoldorfProductData {
  children: InfernoNode,
}
