/**
 * @file
 * @copyright 2023
 * @author garash2k
 * @license ISC
 */
import type { AlertContentWindow } from './types';

const r = require.context('./acw', false, /\.AlertContentWindow\.tsx$/);

const alertContentWindowMap: { [key: string]: AlertContentWindow } = {};
r.keys().forEach((key) => {
  const module = r(key);
  const componentName = key.match(/\/(.*)\.AlertContentWindow\.tsx$/)?.[1];
  if (componentName) {
    alertContentWindowMap[componentName] = module.acw;
  }
});

export const getAlertContentWindow = (
  alertContentWindowName: string,
): AlertContentWindow => {
  const alertContentWindow = alertContentWindowMap[alertContentWindowName];
  if (!alertContentWindow) {
    throw new Error(
      `Unrecognized alert content window name: ${alertContentWindowName}`,
    );
  }
  return alertContentWindow;
};
