/**
 * @file
 * @copyright 2026
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { DisplayDropdown } from './DisplayDropdown';
import { DisplayReference, DisplayReferenceList } from './DisplayReference';
import { DisplayStandard } from './DisplayStandard';
import { DisplayToggleable } from './DisplayToggleable';

export const valueDisplayComponents = {
  dropdown: DisplayDropdown,
  reference: DisplayReference,
  reference_list: DisplayReferenceList,
  value: DisplayStandard,
  toggleable: DisplayToggleable,
};

export const getValueDisplayComponent = (value_type) => {
  if (value_type === undefined) {
    return ({ value }) => value;
  }
  if (value_type in valueDisplayComponents) {
    return valueDisplayComponents[value_type];
  }
};
