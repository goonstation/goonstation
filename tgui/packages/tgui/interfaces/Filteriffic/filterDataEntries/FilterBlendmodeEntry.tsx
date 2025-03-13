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

interface FilterBlendmodeEntryProps {
  name: string;
  value?: string | null;
  filterName: string;
  filterType: string;
}

export const FilterBlendmodeEntry = (props: FilterBlendmodeEntryProps) => {
  const { name, value, filterName, filterType } = props;
  const { act, data } = useBackend<FilterifficData>();

  const filterInfo = data.filter_info;
  const flags = filterInfo[filterType]['blend_mode'];
  return map(flags, (flagField, flagName) => (
    <Button.Checkbox
      checked={value === flagField}
      onClick={() =>
        act('modify_filter_value', {
          name: filterName,
          new_data: {
            [name]: flagField,
          },
        })
      }
    >
      {flagName}
    </Button.Checkbox>
  ));
};
