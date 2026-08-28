/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { configAtom, store } from '../events/store';
import manifest from './cdn-manifest.json';

export const resource = (file: string): string => {
  // Not a hook: `resource()` is called from event handlers and plain helpers.
  const { cdn } = store.get(configAtom);
  if (cdn) {
    if (manifest[file]) file = manifest[file];
    return `${cdn}/${file}`;
  } else {
    const parts = file.split('/');
    return parts[parts.length - 1];
  }
};
