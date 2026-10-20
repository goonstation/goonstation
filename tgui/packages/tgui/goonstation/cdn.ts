/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { atom, useAtomValue } from 'jotai';
import { useCallback } from 'react';

import { configAtom } from '../events/store';
import manifest from './cdn-manifest.json';

/** Keep CDN updates scoped to asset URLs. */
const cdnAtom = atom((get) => get(configAtom).cdn);

/** Pure. Depends on nothing but its arguments. */
function resolve(file: string, cdn: string): string {
  if (!cdn) {
    const parts = file.split('/');
    return parts[parts.length - 1];
  }

  return `${cdn}/${manifest[file] || file}`;
}

/** Resolves assets against the current CDN base. */
export function useResource(): (file: string) => string {
  const cdn = useAtomValue(cdnAtom);

  return useCallback((file: string) => resolve(file, cdn), [cdn]);
}
