/**
 * @file
 * @copyright 2023
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from './types';

import { tgControls } from './tgControls';
import { rpRules } from './rpRules';
import { nukeop } from './nukeop';

export const getAlertContentWindow = (alertContentWindowName: string): AlertContentWindow => {
  switch (alertContentWindowName) {
    case "tgControls":
      return tgControls;
    case "rpRules":
      return rpRules;
    case "nukeop":
      return nukeop;
    default:
      throw new Error(`Unrecognized alert content window name: ${alertContentWindowName}`);
  }
};
