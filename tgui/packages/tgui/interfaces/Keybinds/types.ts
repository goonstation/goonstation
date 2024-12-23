/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

export interface KeybindsData {
  keys: Array<KeybindData>;
}

export interface KeybindData {
  label: string;
  id: string;
  savedValue: string;
  changedValue: string;
}
