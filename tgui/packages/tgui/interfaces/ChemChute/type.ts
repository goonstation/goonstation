/**
 * @file
 * @copyright 2023
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @license MIT
 */

interface ProductData {
  name: string;
  img: string;
  amount: number;
}

export interface ChemChuteData {
  productList: ProductData[];
}
