/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

import { BooleanLike } from 'common/react';

export interface KeybindsData {
  keys: Array<KeybindData>;
  hasChanges: BooleanLike;
  resetting: BooleanLike;
}

export interface KeybindData {
  label: string;
  id: string;
  savedValue: string;
  changedValue: string;
}
