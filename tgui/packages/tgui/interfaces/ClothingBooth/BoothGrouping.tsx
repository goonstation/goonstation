/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { classes } from 'common/react';
import { Stack } from 'tgui-core/components';

import { Image } from '../../components';
import { GroupingTags } from './GroupingTags';
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
            <Stack>
              <Stack.Item grow>{name}</Stack.Item>
              <Stack.Item>
                {cost_min === cost_max
                  ? `${cost_min}⪽`
                  : `${cost_min}⪽ - ${cost_max}⪽`}
              </Stack.Item>
            </Stack>
          </Stack.Item>
          {(grouping_tags.length || itemsCount > 1) && (
            <Stack.Item>
              <Stack style={{ opacity: '0.5' }}>
                {grouping_tags.length && (
                  <Stack.Item grow>
                    <GroupingTags slot={slot} grouping_tags={grouping_tags} />
                  </Stack.Item>
                )}
                {itemsCount > 1 && (
                  <Stack.Item>{itemsCount} variants</Stack.Item>
                )}
              </Stack>
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
    </Stack>
  );
};
