import { Box, Stack } from '../../components';
import { buildFieldComparator, numberComparator } from './utils/Comparator';
import type { ClothingBoothGroupingTagsData } from './type';

export const GroupingTagContainer = (props: Record<string, ClothingBoothGroupingTagsData>) => {
  const groupingTags = Object.values(props);
  const sortedGroupingTags = groupingTags.sort(
    buildFieldComparator((groupingTag) => groupingTag.display_order, numberComparator)
  );

  return (
    <Stack fluid>
      {sortedGroupingTags.map((groupingTag) => (
        <Stack.Item key={groupingTag.name}>
          <GroupingTag {...groupingTag} />
        </Stack.Item>
      ))}
    </Stack>
  );
};

export const GroupingTag = (props: ClothingBoothGroupingTagsData) => {
  const { name, colour } = props;

  return (
    <Box
      className={'clothingbooth__groupingtag'}
      color={colour ? colour : 'white'}
      style={{ border: `0.0835rem solid ${colour ? colour : 'white'}` }}
      px={0.5}>
      {name}
    </Box>
  );
};
