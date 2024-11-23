/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { memo, useCallback } from 'react';
import { Button, Flex, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { GroupingTags as GroupingTags } from './GroupingTags';
import { ItemSwatch as ItemSwatch } from './ItemSwatch';
import type { ClothingBoothData, ClothingBoothGroupingData } from './type';

type PurchaseInfoProps = Pick<
  ClothingBoothData,
  'accountBalance' | 'cash' | 'everythingIsFree' | 'selectedItemName'
> & {
  selectedGrouping?: ClothingBoothGroupingData;
};

const PurchaseInfoView = (props: PurchaseInfoProps) => {
  const {
    accountBalance,
    cash,
    everythingIsFree,
    selectedGrouping,
    selectedItemName,
  } = props;
  const { act } = useBackend();

  const selectedGroupingSlot = selectedGrouping?.slot;
  const selectedGroupingTags = selectedGrouping?.grouping_tags;
  const selectedItem =
    selectedGrouping && selectedItemName
      ? selectedGrouping.clothingbooth_items[selectedItemName]
      : undefined;
  const selectedGroupingClothingBoothItems = Object.values(
    selectedGrouping?.clothingbooth_items ?? {},
  );
  const resolvedCashAvailable = (cash ?? 0) + (accountBalance ?? 0);

  const handlePurchase = useCallback(() => act('purchase'), [act]);
  const handleSelectItem = useCallback(
    (name: string) => act('select-item', { name }),
    [act],
  );

  return (
    <Stack vertical textAlign="center">
      {selectedGrouping && selectedItem ? (
        <>
          <Stack.Item bold>
            <Stack align="center" justify="center">
              <Stack.Item>{selectedGrouping.name}</Stack.Item>
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
          <Stack.Item bold>Selected: {selectedItem.name}</Stack.Item>
          {selectedGroupingClothingBoothItems.length > 1 && (
            <Stack.Item>
              <Flex justify="center" wrap="wrap">
                {Object.values(selectedGrouping.clothingbooth_items).map(
                  (item) => (
                    <Flex.Item key={item.name}>
                      <ItemSwatch
                        {...item}
                        selected={selectedItem.name === item.name}
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
                selectedItem.cost > resolvedCashAvailable && !everythingIsFree
              }
              onClick={handlePurchase}
            >
              {`${
                selectedItem.cost > resolvedCashAvailable && !everythingIsFree
                  ? 'Insufficent Money'
                  : 'Purchase'
              } (${everythingIsFree ? `Free` : `${selectedItem.cost} ⪽`})`}
            </Button>
          </Stack.Item>
        </>
      ) : (
        <Stack.Item bold>Please select an item.</Stack.Item>
      )}
    </Stack>
  );
};

export const PurchaseInfo = memo(PurchaseInfoView);
