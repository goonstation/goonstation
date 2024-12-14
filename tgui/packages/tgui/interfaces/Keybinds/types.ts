/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

export interface KeybindsData {
  keys: Array<KeybindData>;
}

interface KeybindData {
  action: string;
  key: string;
  unparse: string;
}
