/**
 * @file
 * @copyright 2024
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useRef } from 'react';

/**
 * Returns the same value until hashing it returns different.
 *
 * Useful for when you do not want to pass a new object/array reference to a
 * component. Default hashing function is to stringify, good for simple cases
 * but has caveats. Do not use this naively, it will have issues with circular
 * references.
 */
export const useHashedMemo = <T>(value: T, hashFn?: (value: T) => string) => {
  const resolvedHashFn = hashFn ?? JSON.stringify;
  const memoizedValue = useRef(value);
  const memoizedHash = useRef<string | undefined>(undefined);
  // values have not changed, no need to update
  if (value === memoizedValue.current) {
    return memoizedValue.current;
  }
  // hash, compare with previous, update stored values if necessary
  const newHash = resolvedHashFn(value);
  if (newHash !== memoizedHash.current) {
    memoizedHash.current = newHash;
    memoizedValue.current = value;
  }
  return memoizedValue.current;
};
