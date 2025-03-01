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
  canOutput: boolean;
  costSlot?: React.ReactNode;
  image?: string;
  onOutput: () => void;
  outputIcon?: string;
  outputTooltip?: string;
}>;

const ProductListItem = (props: ProductListItemProps) => {
  const {
    canOutput,
    children,
    costSlot,
    image,
    onOutput,
    outputIcon = 'plus',
    outputTooltip,
  } = props;
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
          disabled={!canOutput}
          icon={outputIcon}
          onClick={onOutput}
          tooltip={outputTooltip}
        />
      </Stack.Item>
    </Stack>
  );
};

ProductList.Item = ProductListItem;
