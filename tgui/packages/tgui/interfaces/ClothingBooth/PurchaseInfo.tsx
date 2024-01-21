import { useBackend } from '../../backend';
import { Button, Stack } from '../../components';
import type { ClothingBoothData, ClothingBoothGroupingTagsData, ClothingBoothItemData } from './type';
import { GroupingTag as GroupingTag } from './GroupingTag';
import { ItemSwatch as ItemSwatch } from './ItemSwatch';

export const PurchaseInfo = (_props: unknown, context) => {
  const { act, data } = useBackend<ClothingBoothData>(context);
  const { catalogue, money, selectedGroupingName, selectedItemName } = data;

  let selectedGroupingTags: ClothingBoothGroupingTagsData[] | undefined;
  let selectedItem: ClothingBoothItemData | undefined;
  const selectedGrouping = catalogue[selectedGroupingName];
  if (selectedGrouping) {
    selectedGroupingTags = Object.values(selectedGrouping.grouping_tags);
    selectedItem = selectedGrouping.clothingbooth_items[selectedItemName];
  }

  const handlePurchase = () => act('purchase');
  const handleSelectItem = (name: string) => act('select-item', { name });

  return (
    <Stack vertical textAlign="center">
      {selectedItemName ? (
        <>
          <Stack.Item bold>{selectedGroupingName}</Stack.Item>
          {selectedGroupingTags.length && (
            <Stack.Item>
              <Stack justify="center">
                <Stack.Item bold>Tags: </Stack.Item>
                {selectedGroupingTags.map((groupingTag) => (
                  <Stack.Item key={groupingTag.name}>
                    <GroupingTag {...groupingTag} />
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
          )}
          <Stack.Item bold>Selected: {selectedItemName}</Stack.Item>
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
          <Stack.Item bold>
            <Button color="good" disabled={selectedItem.cost > money} onClick={handlePurchase}>
              {`${selectedItem.cost > money ? 'Insufficent Cash' : 'Purchase'} (${selectedItem.cost}⪽)`}
            </Button>
          </Stack.Item>
        </>
      ) : (
        <Stack.Item bold>Please select an item.</Stack.Item>
      )}
    </Stack>
  );
};
