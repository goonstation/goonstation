/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Flex, Image } from '..';

export const ItemList = (props: ItemListProps) => {
  const {
    items,
    nothing_text = 'Nothing',
  } = props;

  // `items` is either an empty array or an array of `{ name: 'item name', icon: 'base64image' }`.
  if (items === undefined || items.length === 0) {
    return `${nothing_text}`;
  }

  return items.map((item, index, arr) => (
    <Flex
      inline
      align="center"
      key={index}>
      {!!item.icon && (
        <Flex.Item>
          <Image
            height="32px"
            width="32px"
            pixelated
            src={`data:image/png;base64,${item.icon}`}
          />
        </Flex.Item>
      )}
      <Flex.Item
        pr={1}
        pl={0.5}>
        {item.name}
        {`${index === arr.length - 1 ? '' : `, ${index === arr.length - 2 ? 'and ' : ''}`}`}
      </Flex.Item>
    </Flex>
  ));
};

interface ItemListProps {
  items: ItemListItemProps[];
  nothing_text: string;
}

interface ItemListItemProps {
  name: string;
  icon: string;
}
