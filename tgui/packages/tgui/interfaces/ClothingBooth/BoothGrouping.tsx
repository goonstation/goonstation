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
import { shallowDiffers } from 'tgui-core/react';

import { Image } from '../../components';
import { GroupingTags } from './GroupingTags';
import type { ClothingBoothGroupingData } from './type';
import { ClothingBoothData } from './type';

type BoothGroupingProps = Pick<
  ClothingBoothGroupingData,
  'cost_min' | 'cost_max' | 'list_icon' | 'grouping_tags' | 'name' | 'slot'
> &
  Pick<ClothingBoothData, 'everythingIsFree'> & {
    selected: boolean;
    itemsCount: number;
    onSelectGrouping: (itemGroupingName: string) => void;
  };

const BoothGroupingView = (props: BoothGroupingProps) => {
  const {
    cost_min,
    cost_max,
    everythingIsFree,
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
    // conditionally candystripe, as we want to show selected style if selected
    !selected && 'candystripe',
  ]);
  const handleClick = useCallback(
    () => onSelectGrouping(name),
    [onSelectGrouping, name],
  );
  const priceRange =
    cost_min === cost_max ? `${cost_min}⪽` : `${cost_min}⪽ - ${cost_max}⪽`;
  const priceText = everythingIsFree ? (
    <span>
      Free <span style={{ opacity: '0.5' }}>({priceRange})</span>
    </span>
  ) : (
    priceRange
  );

  return (
    <Stack align="center" className={cn} onClick={handleClick} px={0.5} py={1}>
      <Stack.Item>
        <Image pixelated src={`data:image/png;base64,${list_icon}`} />
      </Stack.Item>
      <Stack.Item grow={1}>
        <Stack fill vertical>
          <Stack.Item bold>
            <Stack>
              <Stack.Item grow>{name}</Stack.Item>
              <Stack.Item>{priceText}</Stack.Item>
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
  const { grouping_tags: prevGroupingTags, ...prevRest } = prevProps;
  const { grouping_tags: nextGroupingTags, ...nextRest } = nextProps;
  if (shallowDiffers(prevRest, nextRest)) {
    return false;
  }
  // contents equality comparison for grouping_tags
  if (prevGroupingTags.length !== nextGroupingTags.length) {
    return false;
  }
  if (
    prevGroupingTags.some(
      (prevGroupingTag, i) => prevGroupingTag !== nextGroupingTags[i],
    )
  ) {
    return false;
  }
  return true;
});
