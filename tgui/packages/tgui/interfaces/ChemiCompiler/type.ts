/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

interface button {
  button: boolean;
  cbf: boolean;
}

export interface ChemiCompilerData {
  reservoirs: Array<string>;
  buttons: Array<button>;
  inputValue: string;
  loadTimestamp: number;
  sx: string;
  tx: string;
  ax: string;
}
