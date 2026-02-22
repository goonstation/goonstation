/**
 * @file
 * @copyright 2020
 * @author actioninja (https://github.com/actioninja)
 * @license MIT
 */

import { Box, Button } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import type { FilterifficData } from '../type';

interface FilterIconEntryProps {
  value?: string | null;
  filterName: string;
}

export const FilterIconEntry = (props: FilterIconEntryProps) => {
  const { value, filterName } = props;
  const { act } = useBackend<FilterifficData>();
  return (
    <>
      <Button
        icon="pencil-alt"
        onClick={() =>
          act('modify_icon_value', {
            name: filterName,
          })
        }
      />
      <Box inline ml={1}>
        {value}
      </Box>
    </>
  );
};
