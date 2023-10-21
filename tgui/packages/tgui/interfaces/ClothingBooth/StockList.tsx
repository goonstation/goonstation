import { capitalize } from 'common/string';
import { useBackend, useLocalState } from '../../backend';
import { Button, Divider, Dropdown, Image, Input, Section, Stack } from '../../components';
import { SlotFilters } from './SlotFilters';
import type { ClothingBoothData, ClothingBoothGroupingData } from './type';
import { ClothingBoothSortType } from './type';

type ComparatorFn<T> = (a: T, b: T) => number;
const stringComparator = (a: string, b: string) => (a ?? '').localeCompare(b ?? '');
const numberComparator = (a: number, b: number) => a - b;

const buildFieldComparator =
  <T, V>(fieldFn: (stockItem: T) => V, comparatorFn: ComparatorFn<V>) =>
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

const getSortComparator =
  (usedSortType: ClothingBoothSortType, usedSortDirection: boolean) =>
  (a: ClothingBoothGroupingData, b: ClothingBoothGroupingData) =>
    clothingBoothItemComparators[usedSortType](a, b) * (usedSortDirection ? 1 : -1);

export const StockList = (_, context) => {
  const { data } = useBackend<ClothingBoothData>(context);
  const { itemGroupings, money } = data;
  const [hideUnaffordable] = useLocalState(context, 'hideUnaffordable', false);
  const [slotFilters] = useLocalState(context, 'slotFilters', {});
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [sortType, setSortType] = useLocalState(context, 'sortType', ClothingBoothSortType.Name);
  const [sortAscending, toggleSortAscending] = useLocalState(context, 'sortAscending', true);

  const affordableItemGroupings = hideUnaffordable
    ? itemGroupings.filter((itemGrouping) => money >= itemGrouping.costRange[0])
    : itemGroupings;
  const slotFilteredItemGroupings = Object.values(slotFilters).some((filter) => filter === true)
    ? affordableItemGroupings.filter((itemGrouping) => slotFilters[itemGrouping.slot])
    : affordableItemGroupings;
  const searchTextLower = searchText.toLocaleLowerCase();
  const searchFilteredItemGroupings = searchText
    ? slotFilteredItemGroupings.filter((itemGrouping) => itemGrouping.lowerName.includes(searchTextLower))
    : slotFilteredItemGroupings;
  const sortComparator = getSortComparator(sortType, sortAscending);
  // TODO: const sortedStockInformationList = searchFilteredItemGroupings.sort(sortComparator);
  const sortedStockInformationList = searchFilteredItemGroupings;
  // TODO: tweak season to generic category sort
  /*
  const seasonSortedStockInformationList = sortedStockInformationList.sort(
    getSortComparator(ClothingBoothSortType.Ordinal, false)
  );
  */
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
                  <Input fluid onInput={(e, value) => setSearchText(value)} placeholder="Search by name..." />
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
            <Section fill scrollable>
              {sortedStockInformationList.map((itemGrouping, itemGroupingIndex) => (
                <>
                  {itemGroupingIndex > 0 && <Divider />}
                  <BoothGrouping key={itemGrouping.name} {...itemGrouping} />
                </>
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

interface BoothGroupingProps extends ClothingBoothGroupingData {}

const BoothGrouping = (props: BoothGroupingProps, context) => {
  const { costRange, icon_64: icon64, id, members, name } = props;
  const { act, data } = useBackend<ClothingBoothData>(context);
  const { selectedGroupingId } = data;
  const handleClick = () =>
    selectedGroupingId !== id && act('select-item', { groupingId: id, selectedItemId: members[0]?.item_id });

  return (
    <Stack align="center" className="clothingbooth__boothitem" onClick={handleClick}>
      <Stack.Item>
        <Image pixelated src={`data:image/png;base64,${icon64}`} />
      </Stack.Item>
      <Stack.Item grow={1}>
        <Stack fill vertical>
          <Stack.Item bold>{capitalize(name)}</Stack.Item>
          {/*
          {props.season && (
            <Stack.Item italic className={props.season && `clothingbooth__boothitem__season-${props.season}`}>
              {capitalize(props.season)} Collection
            </Stack.Item>
          )}
          */}
          {members.length > 1 && <Stack.Item italic>{members.length} variants</Stack.Item>}
        </Stack>
      </Stack.Item>
      <Stack.Item bold>
        {typeof costRange === 'number' ? <>{costRange}⪽</> : `${costRange[0]}⪽ - ${costRange[1]}⪽`}
      </Stack.Item>
    </Stack>
  );
};
