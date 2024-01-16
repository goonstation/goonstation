import { Fragment } from 'inferno';
import { classes } from 'common/react';
import { capitalize } from 'common/string';
import { useBackend, useLocalState } from '../../backend';
import { Button, Divider, Dropdown, Image, Input, Section, Stack } from '../../components';
import { SlotFilters } from './SlotFilters';
import type { ClothingBoothData, ClothingBoothGroupingData } from './type';
import { ClothingBoothSlotKey, ClothingBoothSortType } from './type';

/*
type ComparatorFn<T> = (a: T, b: T) => number;
const stringComparator = (a: string, b: string) => (a ?? '').localeCompare(b ?? '');
const numberComparator = (a: number, b: number) => a - b;

const buildFieldComparator
  = <T, V>(fieldFn: (stockItem: T) => V, comparatorFn: ComparatorFn<V>) =>
    (a: T, b: T) =>
      comparatorFn(fieldFn(a), fieldFn(b));

const clothingBoothItemComparators: Record<ClothingBoothSortType, ComparatorFn<ClothingBoothGroupingData>> = {
  [ClothingBoothSortType.Name]: buildFieldComparator((itemGrouping) => itemGrouping.name, stringComparator),
  [ClothingBoothSortType.Price]: buildFieldComparator(
    (itemGrouping) => (typeof itemGrouping === 'number' ? itemGrouping : itemGrouping[0]),
    numberComparator
  ),
  [ClothingBoothSortType.Ordinal]: buildFieldComparator((itemGrouping) => itemGrouping.ordinal, numberComparator),
};

const getSortComparator
  = (usedSortType: ClothingBoothSortType, usedSortDirection: boolean) =>
    (a: ClothingBoothGroupingData, b: ClothingBoothGroupingData) =>
      clothingBoothItemComparators[usedSortType](a, b) * (usedSortDirection ? 1 : -1);
*/

export const StockList = (_props: unknown, context) => {
  const { act, data } = useBackend<ClothingBoothData>(context);
  const { catalogue, money, selectedGroupingName } = data;
  const [hideUnaffordable] = useLocalState(context, 'hideUnaffordable', false);
  const [slotFilters] = useLocalState<Partial<Record<ClothingBoothSlotKey, boolean>>>(context, 'slotFilters', {}); // TODO: shared local state
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [sortType, setSortType] = useLocalState(context, 'sortType', ClothingBoothSortType.Name);
  const [sortAscending, toggleSortAscending] = useLocalState(context, 'sortAscending', true);

  const handleSelectGrouping = (name: string) => act('select-grouping', { name });
  // TODO: check if we need to do this, may be able to send an array instead of a lookup
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
  // const sortComparator = getSortComparator(sortType, sortAscending);
  // TODO: const sortedStockInformationList = searchFilteredItemGroupings.sort(sortComparator);
  const sortedStockInformationList = searchFilteredItemGroupings;
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
                    options={[ClothingBoothSortType.Name, ClothingBoothSortType.Price]}
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

interface BoothGroupingProps extends ClothingBoothGroupingData {
  selectedGroupingName: string | null;
  onSelectGrouping: () => void;
}

const BoothGrouping = (props: BoothGroupingProps) => {
  const { cost_min, cost_max, list_icon, clothingbooth_items, name, onSelectGrouping, selectedGroupingName } = props;
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
          <Stack.Item bold>{capitalize(name)}</Stack.Item>
          {itemsCount > 1 && <Stack.Item italic>{itemsCount} variants</Stack.Item>}
        </Stack>
      </Stack.Item>
      <Stack.Item bold>{cost_min === cost_max ? `${cost_min}⪽` : `${cost_min}⪽ - ${cost_max}⪽`}</Stack.Item>
    </Stack>
  );
};
