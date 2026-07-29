/**
 * @file
 * @copyright 2026
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { Dropdown } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { ValueDisplayParent } from './type';

interface DisplayDropdownProps extends ValueDisplayParent {
  searchable: BooleanLike;
  selected: string;
  options: string[];
  action: [string, object | undefined];
}

/** Component for a variable value that create a dropdown menu. */
export const DisplayDropdown = (props: DisplayDropdownProps) => {
  return (
    <Dropdown
      searchInput={!!props.searchable}
      selected={props.selected}
      displayText={props.selected}
      options={props.options}
      onSelected={(value) =>
        props.onAction(props.action[0], {
          value: value,
          ...props.action[1],
        })
      }
    />
  );
};
