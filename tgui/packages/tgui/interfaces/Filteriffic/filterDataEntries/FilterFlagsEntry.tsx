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

export const FilterFlagsEntry = (props) => {
  const { name, value, filterName, filterType } = props;
  const { act, data } = useBackend<FilterifficData>();

  const filterInfo = data.filter_info;
  const flags = filterInfo[filterType]['flags'];
  return map(flags, (bitField: number, flagName) => (
    <Button.Checkbox
      checked={value & bitField}
      onClick={() =>
        act('modify_filter_value', {
          name: filterName,
          new_data: {
            [name]: value ^ bitField,
          },
        })
      }
    >
      {flagName}
    </Button.Checkbox>
  ));
};
