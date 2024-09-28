/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Button, Flex, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { GroupingTags as GroupingTags } from './GroupingTags';
import { ItemSwatch as ItemSwatch } from './ItemSwatch';
import type {
  ClothingBoothData,
  ClothingBoothItemData,
  ClothingBoothSlotKey,
} from './type';

export const PurchaseInfo = () => {
  const { act, data } = useBackend<ClothingBoothData>();
  const {
    catalogue,
    accountBalance,
    cash,
    selectedGroupingName,
    selectedItemName,
  } = data;

  const selectedGrouping = selectedGroupingName
    ? catalogue[selectedGroupingName]
    : undefined;
  let selectedGroupingSlot: ClothingBoothSlotKey | undefined;
  let selectedGroupingTags: string[] | undefined;
  let selectedItem: ClothingBoothItemData | undefined;
  if (selectedGrouping && selectedItemName) {
    selectedGroupingSlot = selectedGrouping.slot;
    selectedGroupingTags = selectedGrouping.grouping_tags;
    selectedItem = selectedGrouping.clothingbooth_items[selectedItemName];
  }
  const selectedGroupingClothingBoothItems = Object.values(
    selectedGrouping?.clothingbooth_items ?? {},
  );
  const resolvedCashAvailable = (cash ?? 0) + (accountBalance ?? 0);

  const handlePurchase = () => act('purchase');
  const handleSelectItem = (name: string) => act('select-item', { name });

  return (
    <Stack vertical textAlign="center">
      {selectedGrouping && selectedItem && selectedItemName ? (
        <>
          <Stack.Item bold>
            <Stack align="center" justify="center">
              <Stack.Item>{selectedGroupingName}</Stack.Item>
            </Stack>
          </Stack.Item>
          {selectedGroupingTags?.length && selectedGroupingSlot && (
            <Stack.Item>
              <Stack justify="center">
                <Stack.Item bold>Tags: </Stack.Item>
                <Stack.Item style={{ opacity: '0.5' }}>
                  <GroupingTags
                    slot={selectedGroupingSlot}
                    grouping_tags={selectedGroupingTags}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          )}
          <Stack.Item bold>Selected: {selectedItemName}</Stack.Item>
          {selectedGroupingClothingBoothItems.length > 1 && (
            <Stack.Item>
              <Flex justify="center" wrap="wrap">
                {Object.values(selectedGrouping.clothingbooth_items).map(
                  (item) => (
                    <Flex.Item key={item.name}>
                      <ItemSwatch
                        {...item}
                        selected={selectedItemName === item.name}
                        onSelect={() => handleSelectItem(item.name)}
                      />
                    </Flex.Item>
                  ),
                )}
              </Flex>
            </Stack.Item>
          )}
          <Stack.Item bold>
            <Button
              color="good"
              disabled={
                selectedItem.cost > resolvedCashAvailable &&
                !data.everythingIsFree
              }
              onClick={handlePurchase}
            >
              {`${
                selectedItem.cost > resolvedCashAvailable &&
                !data.everythingIsFree
                  ? 'Insufficent Money'
                  : 'Purchase'
              } (${selectedItem.cost}⪽)`}
            </Button>
          </Stack.Item>
        </>
      ) : (
        <Stack.Item bold>Please select an item.</Stack.Item>
      )}
    </Stack>
  );
};
