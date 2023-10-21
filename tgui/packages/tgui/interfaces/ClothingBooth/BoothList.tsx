import { classes } from 'common/react';
import { capitalize } from 'common/string';
import { useBackend } from '../../backend';
import { Box, Divider, Stack } from '../../components';
import type { BoothItemData, ClothingBoothData } from './type';

interface BoothListProps {
  items: BoothItemData[];
}

export const BoothList = (props: BoothListProps) => {
  const { items } = props;
  return (
    <>
      {items.map((item) => (
        <BoothItem key={item.name} item={item} />
      ))}
    </>
  );
};

const BoothItem = (props, context) => {
  const { act, data } = useBackend<ClothingBoothData>(context);
  const { item } = props;

  return (
    <>
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
        <Stack.Item bold>{`${item.cost}⪽`}</Stack.Item>
      </Stack>
      <Divider />
    </>
  );
};
