/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { classes } from 'common/react';
import { memo, useCallback } from 'react';
import { Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Image } from '../../components';
import { GroupingTags } from './GroupingTags';
import type { ClothingBoothGroupingData } from './type';
import { ClothingBoothData } from './type';

type BoothGroupingProps = Pick<
  ClothingBoothGroupingData,
  'cost_min' | 'cost_max' | 'list_icon' | 'grouping_tags' | 'name' | 'slot'
> & {
  selected: boolean;
  itemsCount: number;
  onSelectGrouping: (itemGroupingName: string) => void;
};

const BoothGroupingView = (props: BoothGroupingProps) => {
  const { data } = useBackend<ClothingBoothData>();
  const { everythingIsFree } = data;
  const {
    cost_min,
    cost_max,
    list_icon,
    itemsCount,
    grouping_tags,
    name,
    onSelectGrouping,
    selected,
    slot,
  } = props;
  const cn = classes([
    'clothingbooth__boothitem',
    selected && 'clothingbooth__boothitem--selected',
  ]);
  const handleClick = useCallback(
    () => onSelectGrouping(name),
    [onSelectGrouping, name],
  );

  return (
    <Stack align="center" className={cn} onClick={handleClick} py={0.5}>
      <Stack.Item>
        <Image pixelated src={`data:image/png;base64,${list_icon}`} />
      </Stack.Item>
      <Stack.Item grow={1}>
        <Stack fill vertical>
          <Stack.Item bold>
            <Stack>
              <Stack.Item grow>{name}</Stack.Item>
              <Stack.Item>
                {everythingIsFree
                  ? `Free`
                  : cost_min === cost_max
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

export const BoothGrouping = memo(BoothGroupingView, (prevProps, nextProps) => {
  // shallow comparison for most props
  if (
    prevProps.cost_max !== nextProps.cost_max ||
    prevProps.cost_min !== nextProps.cost_min ||
    prevProps.itemsCount !== nextProps.itemsCount ||
    prevProps.list_icon !== nextProps.list_icon ||
    prevProps.name !== nextProps.name ||
    prevProps.onSelectGrouping !== nextProps.onSelectGrouping ||
    prevProps.selected !== nextProps.selected ||
    prevProps.slot !== nextProps.slot
  ) {
    return false;
  }
  // contents equality comparison for grouping_tags
  if (prevProps.grouping_tags.length !== nextProps.grouping_tags.length) {
    return false;
  }
  for (let i = 0; i < prevProps.grouping_tags.length; i++) {
    if (prevProps.grouping_tags[i] !== nextProps.grouping_tags[i]) {
      return false;
    }
  }
  return true;
});
