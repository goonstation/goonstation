/**
 * @file
 * @copyright 2026
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { VarValueParent } from './type';

interface VarValueProps extends VarValueParent {
  value: string;
}

/** Component for a standard variable value. */
export const VariableValue = (props: VarValueProps) => {
  return props.value;
};
