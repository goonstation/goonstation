/**
 * @file
 * @copyright 2023
 * @author Garash2k (https://github.com/garash2k)
 * @license ISC
 */

import type { BooleanLike } from 'tgui-core/react';

export type PeripheralData = {
  card: string;
  icon: string;
  label: string;
  Clown?: BooleanLike;
  color: any;
  index: number;
};

export type TerminalData = {
  displayHTML: string;
  TermActive: BooleanLike;
  windowName: string;
  fontColor: string;
  bgColor: string;
  peripherals: Array<PeripheralData>;
  inputValue: string;
  loadTimestamp: number;
  ckey: string;
};
