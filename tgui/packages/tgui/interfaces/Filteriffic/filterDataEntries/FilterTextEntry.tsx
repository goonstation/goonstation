/**
 * @file
 * @copyright 2020
 * @author actioninja (https://github.com/actioninja)
 * @license MIT
 */

import { Input } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import type { FilterifficData } from '../type';

export const FilterTextEntry = (props) => {
  const { value, name, filterName } = props;
  const { act } = useBackend<FilterifficData>();

  return (
    <Input
      value={value}
      width="250px"
      onInput={(e, value) =>
        act('modify_filter_value', {
          name: filterName,
          new_data: {
            [name]: value,
          },
        })
      }
    />
  );
};
