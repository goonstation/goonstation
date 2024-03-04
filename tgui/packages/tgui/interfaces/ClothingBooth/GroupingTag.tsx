import { Box, Stack } from '../../components';
import { buildFieldComparator, numberComparator } from './utils/Comparator';
import { ClothingBoothGroupingTagsData, ClothingBoothSlotKey } from './type';

interface GroupingTagContainerProps {
  slot: ClothingBoothSlotKey,
  tags: Record<string, ClothingBoothGroupingTagsData>,
}

interface ClothingBoothSlotDetail {
  id: ClothingBoothSlotKey;
  name: string;
}

export const GroupingTagContainer = (props: GroupingTagContainerProps) => {
  const { slot, tags } = props;
  const groupingTags = Object.values(tags);
  const sortedGroupingTags = groupingTags.sort(
    buildFieldComparator((groupingTag) => groupingTag.display_order, numberComparator)
  );
  const clothingBoothSlotLookup = Object.entries(ClothingBoothSlotKey).reduce((acc, [name, id]) => {
    acc[id] = { id, name };
    return acc;
  }, {} as Record<ClothingBoothSlotKey, ClothingBoothSlotDetail>);

  return (
    <Stack fluid>
      {sortedGroupingTags.map((groupingTag) => (
        <Stack.Item key={groupingTag.name}>
          <GroupingTag {...groupingTag} />
        </Stack.Item>
      ))}
      <Stack.Item>
        <GroupingTag name={clothingBoothSlotLookup[slot].name} />
      </Stack.Item>
    </Stack>
  );
};

export const GroupingTag = (props: ClothingBoothGroupingTagsData) => {
  const { name, colour } = props;

  return (
    <Box
      className={'clothingbooth__groupingtag'}
      color={colour && colour}
      style={{ border: `0.0835rem solid ${colour ? colour : 'currentColor'}` }}
      px={0.5}>
      {name}
    </Box>
  );
};
