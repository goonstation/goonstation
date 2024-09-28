/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license ISC
 */

import { Flex, Image } from 'tgui-core/components';

interface ItemListProps {
  items: ItemListItemProps[];
  nothing_text: string;
}

interface ItemListItemProps {
  name: string;
  iconBase64?: string;
}

export const ItemList = (props: ItemListProps) => {
  const { items, nothing_text = 'Nothing' } = props;

  // `items` is either an empty array or an array of `{ name: 'item name', icon: 'base64image' }`.
  if (items === undefined || items.length === 0) {
    return `${nothing_text}`;
  }

  return items.map((item, index, arr) => (
    <Flex inline align="center" key={index}>
      {!!item.iconBase64 && (
        <Flex.Item>
          <Image
            height="32px"
            width="32px"
            src={`data:image/png;base64,${item.iconBase64}`}
          />
        </Flex.Item>
      )}
      <Flex.Item pr={1} pl={0.5}>
        {item.name}
        {`${index === arr.length - 1 ? '' : `, ${index === arr.length - 2 ? 'and ' : ''}`}`}
      </Flex.Item>
    </Flex>
  ));
};
