/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { useBackend } from '../backend';
import manifest from './cdn-manifest.json';

export const resource = (file: string): string => {
  const { config } = useBackend();
  const { cdn } = config;
  if (cdn) {
    if (manifest[file]) file = manifest[file];
    return `${cdn}/${file}`;
  } else {
    const parts = file.split('/');
    return parts[parts.length - 1];
  }
};
