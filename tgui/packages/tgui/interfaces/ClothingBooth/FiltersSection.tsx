/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useMemo } from 'react';
import { Button, Section, Stack } from 'tgui-core/components';

import {
  ClothingBoothSlotKey,
  SlotFilterLookup,
  TagFilterLookup,
} from './type';

interface FiltersSectionProps {
  onClearSlotFilters: () => void;
  onOpenTagsModal: () => void;
  onToggleSlotFilter: (slot: ClothingBoothSlotKey) => void;
  slotFilters: SlotFilterLookup;
  tagFilters: TagFilterLookup;
}

export const FiltersSection = (props: FiltersSectionProps) => {
  const {
    onClearSlotFilters,
    onOpenTagsModal,
    onToggleSlotFilter,
    slotFilters,
    tagFilters,
  } = props;

  const numAppliedTagFilters = useMemo(
    () =>
      Object.values(tagFilters).filter((tagFilter) => tagFilter === true)
        .length,
    [tagFilters],
  );

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item>
          <Button
            fluid
            align="center"
            color={numAppliedTagFilters > 0 && 'good'}
            onClick={onOpenTagsModal}
          >
            {`Tags${numAppliedTagFilters > 0 ? ` (${numAppliedTagFilters})` : ''}`}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button fluid align="center" onClick={onClearSlotFilters}>
            Clear Slots
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Mask]}
            onClick={() => onToggleSlotFilter(ClothingBoothSlotKey.Mask)}
          >
            Mask
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Glasses]}
            onClick={() => onToggleSlotFilter(ClothingBoothSlotKey.Glasses)}
          >
            Glasses
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Gloves]}
            onClick={() => onToggleSlotFilter(ClothingBoothSlotKey.Gloves)}
          >
            Gloves
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Headwear]}
            onClick={() => onToggleSlotFilter(ClothingBoothSlotKey.Headwear)}
          >
            Headwear
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Shoes]}
            onClick={() => onToggleSlotFilter(ClothingBoothSlotKey.Shoes)}
          >
            Shoes
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Suit]}
            onClick={() => onToggleSlotFilter(ClothingBoothSlotKey.Suit)}
          >
            Suit
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Uniform]}
            onClick={() => onToggleSlotFilter(ClothingBoothSlotKey.Uniform)}
          >
            Uniform
          </Button.Checkbox>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
