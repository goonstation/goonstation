/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

interface ButtonData {
  button: boolean;
  cbf: boolean;
}

export interface ChemiCompilerData {
  reservoirs: Array<string>;
  buttons: Array<ButtonData>;
  inputValue: string;
  loadTimestamp: number;
  sx: string;
  tx: string;
  ax: string;
  theme?: string;
}
