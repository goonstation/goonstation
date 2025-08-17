/**
 * @file
 * @copyright 2020
 * @author actioninja (https://github.com/actioninja)
 * @license MIT
 */

import { NumberInput } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import type { FilterifficData } from '../type';

interface FilterIntegerEntryProps {
  value?: number | null;
  name: string;
  filterName: string;
}

export const FilterIntegerEntry = (props: FilterIntegerEntryProps) => {
  const { value, name, filterName } = props;
  const { act } = useBackend<FilterifficData>();
  return (
    <NumberInput
      value={value ?? 0}
      minValue={-500}
      maxValue={500}
      stepPixelSize={5}
      step={1}
      width="39px"
      tickWhileDragging
      onChange={(value) =>
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
