/**
 * @file
 * @copyright 2026
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { VariableDropdown } from './VariableDropdown';
import { VariableReference, VariableReferenceList } from './VariableReference';
import { VariableToggleable } from './VariableToggleable';
import { VariableValue } from './VariableValue';

const variableValueComponents = {
  value: VariableValue,
  toggleable: VariableToggleable,
  reference: VariableReference,
  reference_list: VariableReferenceList,
  dropdown: VariableDropdown,
};

export const getVariableValueComponent = (value_type) => {
  if (value_type === undefined) {
    return ({ value }) => value;
  }
  if (value_type in variableValueComponents) {
    return variableValueComponents[value_type];
  }
};
