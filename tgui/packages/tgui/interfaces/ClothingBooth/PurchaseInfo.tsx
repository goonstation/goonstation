import { useBackend } from '../../backend';
import { Button, Stack } from '../../components';
import type { ClothingBoothData, ClothingBoothItemData } from './type';
import { ItemSwatch as ItemSwatch } from './ItemSwatch';

export const PurchaseInfo = (_props: unknown, context) => {
  const { act, data } = useBackend<ClothingBoothData>(context);
  const { catalogue, money, selectedGroupingName, selectedItemName } = data;
  let selectedItem: ClothingBoothItemData | undefined;
  const selectedGrouping = catalogue[selectedGroupingName];
  if (selectedGrouping) {
    selectedItem = selectedGrouping.clothingbooth_items[selectedItemName];
  }
  const handlePurchase = () => act('purchase');
  const handleSelectItem = (name: string) => act('select-item', { name });
  return (
    <Stack bold vertical textAlign="center">
      {selectedItemName ? (
        <>
          <Stack.Item>Selected: {selectedItemName}</Stack.Item>
          {Object.values(selectedGrouping.clothingbooth_items).length > 1 && (
            <Stack.Item>
              <Stack justify="center">
                {Object.values(selectedGrouping.clothingbooth_items).map((item) => (
                  <Stack.Item key={item.name}>
                    <ItemSwatch
                      {...item}
                      selected={selectedItemName === item.name}
                      onSelect={() => handleSelectItem(item.name)}
                    />
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
          )}
          <Stack.Item>
            <Button color="green" disabled={selectedItem.cost > money} onClick={handlePurchase}>
              {`${selectedItem.cost > money ? 'Insufficent Cash' : 'Purchase'} (${selectedItem.cost}⪽)`}
            </Button>
          </Stack.Item>
        </>
      ) : (
        <Stack.Item>Please select an item.</Stack.Item>
      )}
    </Stack>
  );
};
