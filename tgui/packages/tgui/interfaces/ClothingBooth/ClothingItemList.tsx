import { Fragment } from 'inferno';
import { classes } from 'common/react';
import { capitalize } from 'common/string';
import { useBackend } from '../../backend';
import { Box, Divider, Stack } from '../../components';
import type { BoothItemData, ClothingBoothData } from './type';

interface BoothListProps {
  items: BoothItemData[];
}

export const ClothingItemList = (props: BoothListProps) => {
  const { items } = props;
  return (
    <>
      {items.map((item, itemIndex) => (
        <Fragment key={item.name}>
          {itemIndex > 0 && <Divider />}
          <ClothingItem item={item} />
        </Fragment>
      ))}
    </>
  );
};

interface BoothItemProps {
  item: BoothItemData;
}

const ClothingItem = (props: BoothItemProps, context) => {
  const { act, data } = useBackend<ClothingBoothData>(context);
  const { item } = props;

  return (
    <Stack
      align="center"
      className={classes([
        'clothingbooth__boothitem',
        item.name === data.selectedItemName && 'clothingbooth__boothitem-selected',
      ])}
      onClick={() => act('select', { path: item.path })}>
      <Stack.Item>
        <img src={`data:image/png;base64,${item.img}`} />
      </Stack.Item>
      <Stack.Item grow={1}>
        <Box bold>{capitalize(item.name)}</Box>
      </Stack.Item>
      <Stack.Item bold>${item.cost}⪽</Stack.Item>
    </Stack>
  );
};
