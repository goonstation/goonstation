/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Fragment, memo, useCallback, useMemo, useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Input,
  Section,
  Stack,
} from 'tgui-core/components';
import { pluralize } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { BoothGrouping } from './BoothGrouping';
import { FiltersSection } from './FiltersSection';
import type {
  ClothingBoothData,
  ClothingBoothGroupingData,
  TagsLookup,
} from './type';
import { ClothingBoothSlotKey, ClothingBoothSortType } from './type';
import type { ComparatorFn } from './utils/comparator';
import {
  buildFieldComparator,
  numberComparator,
  stringComparator,
} from './utils/comparator';

const clothingBoothItemComparators: Record<
  ClothingBoothSortType,
  ComparatorFn<ClothingBoothGroupingData>
> = {
  [ClothingBoothSortType.Name]: buildFieldComparator(
    (itemGrouping) => itemGrouping.name,
    stringComparator,
  ),
  [ClothingBoothSortType.Price]: buildFieldComparator(
    (itemGrouping) => itemGrouping.cost_min,
    numberComparator,
  ),
  [ClothingBoothSortType.Variants]: buildFieldComparator(
    (itemGrouping) => Object.values(itemGrouping.clothingbooth_items).length,
    numberComparator,
  ),
};

const getClothingBoothGroupingSortComparator =
  (usedSortType: ClothingBoothSortType, usedSortDirection: boolean) =>
  (a: ClothingBoothGroupingData, b: ClothingBoothGroupingData) =>
    clothingBoothItemComparators[usedSortType](a, b) *
    (usedSortDirection ? 1 : -1);

const useProcessCatalogue = (
  catalogue: Record<string, ClothingBoothGroupingData>,
  hideUnaffordable: boolean,
  cashAvailable: number,
  slotFilters: Partial<Record<ClothingBoothSlotKey, boolean>>,
  tagFilters: TagsLookup,
  searchTextLower: string,
  sortType: ClothingBoothSortType,
  sortAscending: boolean,
) => {
  const catalogueItems = useMemo(() => Object.values(catalogue), [catalogue]);
  const affordableItemGroupings = useMemo(
    () =>
      hideUnaffordable
        ? catalogueItems.filter(
            (catalogueGrouping) => cashAvailable >= catalogueGrouping.cost_min,
          )
        : catalogueItems,
    [cashAvailable, catalogueItems, hideUnaffordable],
  );
  const hasSlotFiltersApplied = useMemo(
    () => Object.values(slotFilters).some((filter) => filter),
    [slotFilters],
  );
  const slotFilteredItemGroupings = useMemo(
    () =>
      hasSlotFiltersApplied
        ? affordableItemGroupings.filter(
            (itemGrouping) => slotFilters[itemGrouping.slot],
          )
        : affordableItemGroupings,
    [affordableItemGroupings, hasSlotFiltersApplied, slotFilters],
  );
  const hasTagFiltersApplied = useMemo(
    () => !!tagFilters && Object.values(tagFilters).includes(true),
    [tagFilters],
  );
  const tagFilteredItemGroupings = useMemo(
    () =>
      hasTagFiltersApplied
        ? slotFilteredItemGroupings.filter((itemGrouping) =>
            itemGrouping.grouping_tags.some(
              (groupingTag) => !!tagFilters[groupingTag],
            ),
          )
        : slotFilteredItemGroupings,
    [hasTagFiltersApplied, slotFilteredItemGroupings, tagFilters],
  );
  const searchFilteredItemGroupings = useMemo(
    () =>
      searchTextLower
        ? tagFilteredItemGroupings.filter((itemGrouping) =>
            itemGrouping.name.toLocaleLowerCase().includes(searchTextLower),
          )
        : tagFilteredItemGroupings,
    [searchTextLower, tagFilteredItemGroupings],
  );
  const sortComparator = useMemo(
    () => getClothingBoothGroupingSortComparator(sortType, sortAscending),
    [sortAscending, sortType],
  );
  const sortedStockInformationList = useMemo(
    () => [...searchFilteredItemGroupings].sort(sortComparator),
    [searchFilteredItemGroupings, sortComparator],
  );
  return sortedStockInformationList;
};

type StockListProps = Pick<
  ClothingBoothData,
  'accountBalance' | 'cash' | 'catalogue' | 'selectedGroupingName'
> & {
  onOpenTagsModal: () => void;
  tagFilters: TagsLookup;
};

const StockListView = (props: StockListProps) => {
  const {
    accountBalance,
    cash,
    catalogue,
    onOpenTagsModal,
    selectedGroupingName,
    tagFilters,
  } = props;
  const { act } = useBackend();
  const resolvedCashAvailable = (cash ?? 0) + (accountBalance ?? 0);

  const [hideUnaffordable, setHideUnaffordable] = useState(false);
  // TODO: use context for slot filters
  const [slotFilters] = useState<
    Partial<Record<ClothingBoothSlotKey, boolean>>
  >({});
  const [searchText, setSearchText] = useState('');
  const searchTextLower = searchText.toLocaleLowerCase();
  const [sortType, setSortType] = useState(ClothingBoothSortType.Name);
  const [sortAscending, setSortAscending] = useState(true);

  const handleSelectGrouping = useCallback(
    (name: string) => act('select-grouping', { name }),
    [act],
  );
  const handleSetSortType = useCallback(
    (value: ClothingBoothSortType) => setSortType(value),
    [],
  );

  const processedCatalogue = useProcessCatalogue(
    catalogue,
    hideUnaffordable,
    resolvedCashAvailable,
    slotFilters,
    tagFilters,
    searchTextLower,
    sortType,
    sortAscending,
  );

  return (
    <Stack fill>
      <Stack.Item>
        <FiltersSection
          onOpenTagsModal={onOpenTagsModal}
          tagFilters={tagFilters}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill vertical>
          <Stack.Item>
            <Section>
              <Stack align="center" justify="space-between">
                <Stack.Item grow>
                  <Input
                    fluid
                    onInput={(_e: unknown, value: string) =>
                      setSearchText(value)
                    }
                    placeholder="Search by name..."
                  />
                </Stack.Item>
                <Stack.Item grow>
                  <Dropdown
                    className="clothingbooth__dropdown"
                    displayText={`Sort: ${sortType}`}
                    onSelected={handleSetSortType}
                    options={[
                      ClothingBoothSortType.Name,
                      ClothingBoothSortType.Price,
                      ClothingBoothSortType.Variants,
                    ]}
                    selected={sortType}
                    width="100%"
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon={
                      sortAscending
                        ? 'arrow-down-short-wide'
                        : 'arrow-down-wide-short'
                    }
                    onClick={() => setSortAscending(!sortAscending)}
                    tooltip={`Sort Direction: ${sortAscending ? 'Ascending' : 'Descending'}`}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <Stack align="center" justify="space-between">
                <Stack.Item>
                  <Box as="span" style={{ opacity: '0.5' }}>
                    {`${processedCatalogue.length} ${pluralize('grouping', processedCatalogue.length)} available`}
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Button.Checkbox
                    checked={hideUnaffordable}
                    onClick={() => setHideUnaffordable(!hideUnaffordable)}
                  >
                    Hide Unaffordable
                  </Button.Checkbox>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <StockListSection
              onSelectGrouping={handleSelectGrouping}
              groupings={processedCatalogue}
              selectedGroupingName={selectedGroupingName}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

export const StockList = memo(StockListView);

interface StockListSectionProps {
  groupings: ClothingBoothGroupingData[];
  onSelectGrouping: (name: string) => void;
  selectedGroupingName: string | null;
}

const StockListSectionView = (props: StockListSectionProps) => {
  const { groupings, onSelectGrouping, selectedGroupingName } = props;
  return (
    <Section fill scrollable>
      {groupings.map((itemGrouping, itemGroupingIndex) => (
        <Fragment key={itemGrouping.name}>
          {itemGroupingIndex > 0 && <Divider />}
          <BoothGrouping
            {...itemGrouping}
            itemsCount={Object.keys(itemGrouping.clothingbooth_items).length}
            onSelectGrouping={onSelectGrouping}
            selected={selectedGroupingName === itemGrouping.name}
          />
        </Fragment>
      ))}
    </Section>
  );
};

const StockListSection = memo(StockListSectionView);
