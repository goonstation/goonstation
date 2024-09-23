/**
 * @file
 * @copyright 2023
 * @author garash2k
 * @license ISC
 */
import { nukeop } from './nukeop';
import { rpRules } from './rpRules';
import { tgControls } from './tgControls';
import type { AlertContentWindow } from './types';

export const getAlertContentWindow = (
  alertContentWindowName: string,
): AlertContentWindow => {
  switch (alertContentWindowName) {
    case 'tgControls':
      return tgControls;
    case 'rpRules':
      return rpRules;
    case 'nukeop':
      return nukeop;
    default:
      throw new Error(
        `Unrecognized alert content window name: ${alertContentWindowName}`,
      );
  }
};
