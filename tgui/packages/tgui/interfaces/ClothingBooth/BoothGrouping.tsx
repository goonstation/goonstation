import { classes } from 'common/react';
import { Image, Stack } from '../../components';
import { GroupingTagContainer as GroupingTagContainer } from './GroupingTag';
import type { ClothingBoothGroupingData } from './type';

interface BoothGroupingProps extends ClothingBoothGroupingData {
  selectedGroupingName: string | null;
  onSelectGrouping: () => void;
}

export const BoothGrouping = (props: BoothGroupingProps) => {
  const {
    cost_min,
    cost_max,
    list_icon,
    clothingbooth_items,
    grouping_tags,
    name,
    onSelectGrouping,
    selectedGroupingName,
    slot,
  } = props;
  const cn = classes([
    'clothingbooth__boothitem',
    selectedGroupingName === name && 'clothingbooth__boothitem--selected',
  ]);
  const itemsCount = Object.values(clothingbooth_items).length;

  return (
    <Stack align="center" className={cn} onClick={onSelectGrouping} py={0.5}>
      <Stack.Item>
        <Image pixelated src={`data:image/png;base64,${list_icon}`} />
      </Stack.Item>
      <Stack.Item grow={1}>
        <Stack fill vertical>
          <Stack.Item bold>
            <Stack fluid>
              <Stack.Item grow>{name}</Stack.Item>
              <Stack.Item>{cost_min === cost_max ? `${cost_min}⪽` : `${cost_min}⪽ - ${cost_max}⪽`}</Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Stack fluid style={{ opacity: '0.5' }}>
              {Object.values(grouping_tags).length && (
                <Stack.Item grow>
                  <GroupingTagContainer slot={slot} grouping_tags={grouping_tags} />
                </Stack.Item>
              )}
              {itemsCount > 1 && <Stack.Item>{itemsCount} variants</Stack.Item>}
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};
