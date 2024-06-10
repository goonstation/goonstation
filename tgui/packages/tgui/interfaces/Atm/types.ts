/**
 * @file
 * @copyright 2022
 * @author DisturbHerb (https://github.com/DisturbHerb/)
 * @license MIT
 */

export interface AtmData {
  accountName: string;
  accountBalance: number;
  cardname: string;
  clientKey: string;
  loggedIn: number;
  message: any;
  name: string;
  scannedCard: string;
  spacebuxBalance: number;
}

export enum AtmTabKeys {
  Teller,
  Spacebux,
}
