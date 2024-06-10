/**
 * @file
 * @copyright 2023
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from './types';

import { tgControls } from './tgControls';

export const getAlertContentWindow = (alertContentWindowName: string): AlertContentWindow => {
  switch (alertContentWindowName) {
    case "tgControls":
      return tgControls;
    default:
      throw new Error(`Unrecognized alert content window name: ${alertContentWindowName}`);
  }
};
