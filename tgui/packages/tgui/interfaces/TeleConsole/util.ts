/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { toFixed } from 'common/math';
import { decodeHtmlEntities } from 'common/string';

export const formatDecimal = (value: number) => toFixed(value, 2);
export const formatCoordinates = (x: number, y: number, z: number) =>
  `${formatDecimal(x)} / ${formatDecimal(y)} / ${z}`;
export const formatReadout = (readout: string) => decodeHtmlEntities(readout);
