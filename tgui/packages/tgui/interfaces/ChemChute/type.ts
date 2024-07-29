/**
 * @file
 * @copyright 2023
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @license MIT
 */

export type Product = {
  name: string;
  img: string;
  amount: number;
};

export interface ChemChuteData {
  productList: Product[];
}
