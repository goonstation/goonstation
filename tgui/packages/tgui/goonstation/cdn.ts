/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { useBackend } from '../backend';
import manifest from './cdn-manifest.json';

interface CDNData {
  cdn: string;
}

export const resource = (file: string): string => {
  const { data } = useBackend<CDNData>();
  const { cdn } = data;
  if (cdn) {
    if (manifest[file]) file = manifest[file];
    return `${cdn}/${file}`;
  } else {
    const parts = file.split('/');
    return parts[parts.length - 1];
  }
};
