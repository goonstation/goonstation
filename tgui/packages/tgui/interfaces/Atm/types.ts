/**
 * @copyright 2022
 * @author DisturbHerb (https://github.com/DisturbHerb/)
 * @license MIT
 */

export interface AtmData {
  accountName: string;
  accountBalance: number;
	cardname: string;
  loggedIn: number;
  scannedCard: string;
  spacebuxBalance: number;
}

export enum AtmTabKeys {
  Teller,
  Spacebux,
}
