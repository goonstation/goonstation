import { useBackend } from '../../backend';
import { Button, Stack } from '../../components';
import type { ClothingBoothData } from './type';

export const PurchaseInfo = (_, context) => {
  const { act, data } = useBackend<ClothingBoothData>(context);
  return (
    <Stack bold vertical textAlign="center">
      {data.selectedItemName ? (
        <>
          <Stack.Item>Selected: ${data.selectedItemName}</Stack.Item>
          <Stack.Item>Price: ${data.selectedItemCost}⪽</Stack.Item>
          <Stack.Item>
            <Button color="green" disabled={data.selectedItemCost > data.money} onClick={() => act('purchase')}>
              {!(data.selectedItemCost > data.money) ? 'Purchase' : 'Insufficient Cash'}
            </Button>
          </Stack.Item>
        </>
      ) : (
        <Stack.Item>Please select an item.</Stack.Item>
      )}
    </Stack>
  );
};
