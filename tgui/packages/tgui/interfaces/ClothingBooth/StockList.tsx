import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../../backend';
import { Button, Divider, Dropdown, Input, Section, Stack } from '../../components';
import { BoothGrouping } from './BoothGrouping';
import { SlotFilters } from './SlotFilters';
import { buildFieldComparator, numberComparator, stringComparator } from './utils/Comparator';
import type { ComparatorFn } from './utils/Comparator';
import type { ClothingBoothData, ClothingBoothGroupingData } from './type';
import { ClothingBoothSlotKey, ClothingBoothSortType } from './type';

const clothingBoothItemComparators: Record<ClothingBoothSortType, ComparatorFn<ClothingBoothGroupingData>> = {
  [ClothingBoothSortType.Name]: buildFieldComparator((itemGrouping) => itemGrouping.name, stringComparator),
  [ClothingBoothSortType.Price]: buildFieldComparator((itemGrouping) => itemGrouping.cost_min, numberComparator),
  [ClothingBoothSortType.Variants]: buildFieldComparator(
    (itemGrouping) => Object.values(itemGrouping.clothingbooth_items).length,
    numberComparator
  ),
};

const getSortComparator
  = (usedSortType: ClothingBoothSortType, usedSortDirection: boolean) =>
    (a: ClothingBoothGroupingData, b: ClothingBoothGroupingData) =>
      clothingBoothItemComparators[usedSortType](a, b) * (usedSortDirection ? 1 : -1);

export const StockList = (_props: unknown, context) => {
  const { act, data } = useBackend<ClothingBoothData>(context);
  const { catalogue, money, selectedGroupingName } = data;
  const [hideUnaffordable] = useLocalState(context, 'hideUnaffordable', false);
  const [slotFilters] = useLocalState<Partial<Record<ClothingBoothSlotKey, boolean>>>(context, 'slotFilters', {}); // TODO: shared local state
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [sortType, setSortType] = useLocalState(context, 'sortType', ClothingBoothSortType.Name);
  const [sortAscending, toggleSortAscending] = useLocalState(context, 'sortAscending', true);

  const handleSelectGrouping = (name: string) => act('select-grouping', { name });
  const catalogueItems = Object.values(catalogue);

  const affordableItemGroupings = hideUnaffordable
    ? catalogueItems.filter((catalogueGrouping) => money >= catalogueGrouping.cost_min)
    : catalogueItems;
  const slotFilteredItemGroupings = Object.values(slotFilters).some((filter) => filter)
    ? affordableItemGroupings.filter((itemGrouping) => slotFilters[itemGrouping.slot])
    : affordableItemGroupings;
  const searchTextLower = searchText.toLocaleLowerCase();
  const searchFilteredItemGroupings = searchText
    ? slotFilteredItemGroupings.filter((itemGrouping) =>
      itemGrouping.name.toLocaleLowerCase().includes(searchTextLower)
    )
    : slotFilteredItemGroupings;
  const sortComparator = getSortComparator(sortType, sortAscending);
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
                    onClick={() => toggleSortAscending(!sortAscending)}
                    tooltip={`Sort Direction: ${sortAscending ? 'Ascending' : 'Descending'}`}
                  />
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
