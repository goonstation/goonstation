/**
 * @file
 * @copyright 2025
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { PropsWithChildren } from 'react';
import { Button, Image, Stack } from 'tgui-core/components';

type ProductListProps = PropsWithChildren<{}>;

export const ProductList = (props: ProductListProps) => {
  const { children } = props;
  return children;
};

export type ProductListItemProps = PropsWithChildren<{
  buyTooltip?: string;
  canBuy: boolean;
  costSlot?: React.ReactNode;
  image?: string;
  onBuy: () => void;
}>;

const ProductListItem = (props: ProductListItemProps) => {
  const { buyTooltip, canBuy, children, costSlot, image, onBuy } = props;
  return (
    <Stack align="center" className="candystripe" px={1}>
      {image && (
        <Stack.Item>
          <Image src={`data:image/png;base64,${image}`} />
        </Stack.Item>
      )}
      <Stack.Item grow>{children}</Stack.Item>
      {costSlot !== null && costSlot !== undefined && (
        <Stack.Item>{costSlot}</Stack.Item>
      )}
      <Stack.Item>
        <Button
          disabled={!canBuy}
          icon="plus"
          onClick={onBuy}
          tooltip={buyTooltip}
        />
      </Stack.Item>
    </Stack>
  );
};

ProductList.Item = ProductListItem;
