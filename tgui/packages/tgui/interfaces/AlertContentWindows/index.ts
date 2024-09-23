/**
 * @file
 * @copyright 2023
 * @author garash2k
 * @license ISC
 */
import type { AlertContentWindow } from './types';

const r = require.context('.', false, /\.AlertContentWindow\.tsx$/);

export const getAlertContentWindow = (
  alertContentWindowName: string,
): AlertContentWindow => {
  const acwKey = r
    .keys()
    .find((k) =>
      k.endsWith(`/${alertContentWindowName}.AlertContentWindow.tsx`),
    );
  if (!acwKey) {
    throw new Error(
      `Unrecognized alert content window name: ${alertContentWindowName}`,
    );
  }
  return r(acwKey).acw;
};
