/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Fragment, useState } from 'react';
import { useBackend } from '../../backend';
import { Box, Button, Divider, Dropdown, Input, Section, Stack } from 'tgui-core/components';
import { BoothGrouping } from './BoothGrouping';
import { SlotFilters } from './SlotFilters';
import { buildFieldComparator, numberComparator, stringComparator } from './utils/comparator';
import { pluralize } from 'tgui-core/string';
import type { ComparatorFn } from './utils/comparator';
import type { ClothingBoothData, ClothingBoothGroupingData } from './type';
import { ClothingBoothSlotKey, ClothingBoothSortType } from './type';
import { LocalStateKey } from './utils/enum';

const clothingBoothItemComparators: Record<ClothingBoothSortType, ComparatorFn<ClothingBoothGroupingData>> = {
  [ClothingBoothSortType.Name]: buildFieldComparator((itemGrouping) => itemGrouping.name, stringComparator),
  [ClothingBoothSortType.Price]: buildFieldComparator((itemGrouping) => itemGrouping.cost_min, numberComparator),
  [ClothingBoothSortType.Variants]: buildFieldComparator(
    (itemGrouping) => Object.values(itemGrouping.clothingbooth_items).length,
    numberComparator
  ),
};

const getClothingBoothGroupingSortComparator
  = (usedSortType: ClothingBoothSortType, usedSortDirection: boolean) =>
    (a: ClothingBoothGroupingData, b: ClothingBoothGroupingData) =>
      clothingBoothItemComparators[usedSortType](a, b) * (usedSortDirection ? 1 : -1);

export const StockList = (_props: unknown) => {
  const { act, data } = useBackend<ClothingBoothData>();
  const { catalogue, accountBalance, cash, selectedGroupingName } = data;
  const catalogueItems = Object.values(catalogue);

  const [hideUnaffordable, setHideUnaffordable] = useState(LocalStateKey.HideUnaffordable, false);
  const [slotFilters] = useState<Partial<Record<ClothingBoothSlotKey, boolean>>>(
    LocalStateKey.SlotFilters,
    {}
  );
  const [searchText, setSearchText] = useState(LocalStateKey.SearchText, '');
  const [sortType, setSortType] = useState(LocalStateKey.SortType, ClothingBoothSortType.Name);
  const [sortAscending, setSortAscending] = useState(LocalStateKey.SortAscending, true);

  const [tagFilters] = useState<Partial<Record<string, boolean>>>(LocalStateKey.TagFilters, {});

  const handleSelectGrouping = (name: string) => act('select-grouping', { name });

  const affordableItemGroupings = hideUnaffordable
    ? catalogueItems.filter((catalogueGrouping) => cash + accountBalance >= catalogueGrouping.cost_min)
    : catalogueItems;
  const slotFilteredItemGroupings = Object.values(slotFilters).some((filter) => filter)
    ? affordableItemGroupings.filter((itemGrouping) => slotFilters[itemGrouping.slot])
    : affordableItemGroupings;
  const tagFiltersApplied = !!tagFilters && Object.values(tagFilters).includes(true);
  const tagFilteredItemGroupings = tagFiltersApplied
    ? slotFilteredItemGroupings.filter((itemGrouping) =>
      itemGrouping.grouping_tags.some((groupingTag) => !!tagFilters[groupingTag])
    )
    : slotFilteredItemGroupings;
  const searchTextLower = searchText.toLocaleLowerCase();
  const searchFilteredItemGroupings = searchText
    ? tagFilteredItemGroupings.filter((itemGrouping) => itemGrouping.name.toLocaleLowerCase().includes(searchTextLower))
    : tagFilteredItemGroupings;
  const sortComparator = getClothingBoothGroupingSortComparator(sortType, sortAscending);
  const sortedStockInformationList = searchFilteredItemGroupings.sort(sortComparator);

  return (
    <Stack fill>
      <Stack.Item>
        <SlotFilters />
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill vertical>
          <Stack.Item>
            <Section>
              <Stack fluid align="center" justify="space-between">
                <Stack.Item grow>
                  <Input
                    fluid
                    onInput={(_e: unknown, value: string) => setSearchText(value)}
                    placeholder="Search by name..."
                  />
                </Stack.Item>
                <Stack.Item grow>
                  <Dropdown
                    noscroll
                    className="clothingbooth__dropdown"
                    displayText={`Sort: ${sortType}`}
                    onSelected={(value) => setSortType(value)}
                    options={[ClothingBoothSortType.Name, ClothingBoothSortType.Price, ClothingBoothSortType.Variants]}
                    selected={sortType}
                    width="100%"
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon={sortAscending ? 'arrow-down-short-wide' : 'arrow-down-wide-short'}
                    onClick={() => setSortAscending(!sortAscending)}
                    tooltip={`Sort Direction: ${sortAscending ? 'Ascending' : 'Descending'}`}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <Stack fluid align="center" justify="space-between">
                <Stack.Item>
                  <Box as="span" style={{ opacity: '0.5' }}>
                    {sortedStockInformationList.length} {pluralize('grouping', sortedStockInformationList.length)}{' '}
                    available
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Button.Checkbox
                    checked={hideUnaffordable}
                    onClick={() => setHideUnaffordable(!hideUnaffordable)}>
                    Hide Unaffordable
                  </Button.Checkbox>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <StockListSection
              onSelectGrouping={handleSelectGrouping}
              groupings={sortedStockInformationList}
              selectedGroupingName={selectedGroupingName}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

interface StockListSectionProps {
  groupings: ClothingBoothGroupingData[];
  onSelectGrouping: (name: string) => void;
  selectedGroupingName: string | null;
}

const StockListSection = (props: StockListSectionProps) => {
  const { groupings, onSelectGrouping, selectedGroupingName } = props;
  return (
    <Section fill scrollable>
      {groupings.map((itemGrouping, itemGroupingIndex) => (
        <Fragment key={itemGrouping.name}>
          {itemGroupingIndex > 0 && <Divider />}
          <BoothGrouping
            {...itemGrouping}
            onSelectGrouping={() => onSelectGrouping(itemGrouping.name)}
            selectedGroupingName={selectedGroupingName}
          />
        </Fragment>
      ))}
    </Section>
  );
};
