/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

export enum DisposalChuteState {
  Off = 0, // DISPOSAL_CHUTE_OFF
  Charging = 1, // DISPOSAL_CHUTE_CHARGING
  Charged = 2, // DISPOSAL_CHUTE_CHARGED
}

export interface DisposalChuteConfig {
  pumpColor: string,
  pumpText: string,
}

export type DisposalChuteConfigLookup = {
  [key in DisposalChuteState]: DisposalChuteConfig;
}

export interface DisposalChuteData {
  name: string,
  destinations: string[],
  destinationTag: string,
  flush: boolean,
  mode: DisposalChuteState,
  pressure: number,
}
