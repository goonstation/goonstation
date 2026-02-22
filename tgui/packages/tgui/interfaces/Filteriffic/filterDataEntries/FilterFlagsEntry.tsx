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

interface FilterFlagsEntryProps {
  name: string;
  filterName: string;
  value?: number | null;
  filterType;
}

export const FilterFlagsEntry = (props: FilterFlagsEntryProps) => {
  const { name, value, filterName, filterType } = props;
  const { act, data } = useBackend<FilterifficData>();

  const filterInfo = data.filter_info;
  const flags = filterInfo[filterType]['flags'];
  const sanitizedValue = value ?? 0;
  return map(flags, (bitField: number, flagName) => (
    <Button.Checkbox
      checked={sanitizedValue & bitField}
      onClick={() =>
        act('modify_filter_value', {
          name: filterName,
          new_data: {
            [name]: sanitizedValue ^ bitField,
          },
        })
      }
    >
      {flagName}
    </Button.Checkbox>
  ));
};
