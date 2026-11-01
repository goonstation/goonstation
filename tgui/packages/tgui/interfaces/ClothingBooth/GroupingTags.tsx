/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Box, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import {
  ClothingBoothData,
  ClothingBoothGroupingTagsData,
  ClothingBoothSlotKey,
} from './type';
import { buildFieldComparator, numberComparator } from './utils/comparator';

interface GroupingTagContainerProps {
  slot: ClothingBoothSlotKey;
  grouping_tags: string[];
}

interface ClothingBoothSlotDetail {
  id: ClothingBoothSlotKey;
  name: string;
}

const clothingBoothSlotLookup = Object.entries(ClothingBoothSlotKey).reduce(
  (acc, [name, id]) => {
    acc[id] = { id, name };
    return acc;
  },
  {} as Record<ClothingBoothSlotKey, ClothingBoothSlotDetail>,
);

export const GroupingTags = (props: GroupingTagContainerProps) => {
  const { data } = useBackend<ClothingBoothData>();
  const { tags } = data;
  const { slot, grouping_tags } = props;
  const sortedGroupingTags = grouping_tags.sort(
    buildFieldComparator(
      (groupingTag) => tags[groupingTag].display_order,
      numberComparator,
    ),
  );

  return (
    <Stack>
      {sortedGroupingTags.map((groupingTag) => (
        <Stack.Item key={tags[groupingTag].name}>
          <GroupingTag {...tags[groupingTag]} />
        </Stack.Item>
      ))}
      <Stack.Item>
        <GroupingTag name={clothingBoothSlotLookup[slot].name} />
      </Stack.Item>
    </Stack>
  );
};

interface GroupingTagProps extends ClothingBoothGroupingTagsData {}

const GroupingTag = (props: GroupingTagProps) => {
  const { name, color } = props;

  return (
    <Box
      className="clothingbooth__groupingtag"
      color={color}
      style={{ border: `1px solid ${color ? color : 'currentColor'}` }}
      px={0.5}
    >
      {name}
    </Box>
  );
};
