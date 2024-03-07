import { Box, Stack } from '../../components';
import { buildFieldComparator, numberComparator } from './utils/Comparator';
import { ClothingBoothData, ClothingBoothGroupingTagsData, ClothingBoothSlotKey } from './type';
import { useBackend } from '../../backend';

interface GroupingTagContainerProps {
  slot: ClothingBoothSlotKey,
  grouping_tags: string[],
}

interface ClothingBoothSlotDetail {
  id: ClothingBoothSlotKey;
  name: string;
}

export const GroupingTagContainer = (props: GroupingTagContainerProps, context) => {
  const { data } = useBackend<ClothingBoothData>(context);
  const { tags } = data;
  const { slot, grouping_tags } = props;
  const groupingTagsObject = Object.values(grouping_tags);
  const sortedGroupingTags = groupingTagsObject.sort(
    buildFieldComparator((groupingTag) => tags[groupingTag].display_order, numberComparator)
  );
  const clothingBoothSlotLookup = Object.entries(ClothingBoothSlotKey).reduce((acc, [name, id]) => {
    acc[id] = { id, name };
    return acc;
  }, {} as Record<ClothingBoothSlotKey, ClothingBoothSlotDetail>);

  return (
    <Stack fluid>
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
