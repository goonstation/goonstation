/**
 * @file
 * @copyright 2026
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { ValueDisplayParent } from './type';

interface DisplayStandardProps extends ValueDisplayParent {
  value: string;
}

/** Component for a standard variable value. */
export const DisplayStandard = (props: DisplayStandardProps) => {
  return props.value;
};
