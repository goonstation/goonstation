/**
 * @file
 * @copyright 2020
 * @author actioninja (https://github.com/actioninja)
 * @license MIT
 */

import { map } from 'common/collections';
import { Button } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import type { FilterifficData } from '../type';

interface FilterSpaceEntryProps {
  name: string;
  value;
  filterName: string;
  filterType: string;
}

export const FilterSpaceEntry = (props: FilterSpaceEntryProps) => {
  const { name, value, filterName, filterType } = props;
  const { act, data } = useBackend<FilterifficData>();

  const filterInfo = data.filter_info;
  const flags = filterInfo[filterType]?.['space'];
  return map(flags, (spaceField, flagName) => (
    <Button.Checkbox
      checked={value === spaceField}
      onClick={() =>
        act('modify_filter_value', {
          name: filterName,
          new_data: {
            [name]: spaceField,
          },
        })
      }
    >
      {flagName}
    </Button.Checkbox>
  ));
};
