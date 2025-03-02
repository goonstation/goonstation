/**
 * @file
 * @copyright 2025
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import {
  ComponentProps,
  createContext,
  PropsWithChildren,
  useContext,
  useMemo,
} from 'react';
import { Button, Image, Table } from 'tgui-core/components';

interface ProductListConfig {
  showCount?: boolean;
  showImage?: boolean;
  showOutput?: boolean;
}

const defaultProductListConfig = {
  showImage: true,
  showOutput: true,
};

const ProductListConfigContext = createContext<ProductListConfig>(
  defaultProductListConfig,
);

type ProductListProps = PropsWithChildren<ProductListConfig>;

export const ProductList = (props: ProductListProps) => {
  const { children, showCount, showOutput = true, showImage = true } = props;
  const productListConfig = useMemo(
    () => ({
      showCount,
      showOutput,
      showImage,
    }),
    [showCount, showOutput, showImage],
  );
  return (
    <ProductListConfigContext.Provider value={productListConfig}>
      <Table>{children}</Table>
    </ProductListConfigContext.Provider>
  );
};

export type ProductListItemProps = PropsWithChildren<{
  count?: number;
  extraCellsSlot?: React.ReactNode;
  image?: string;
  outputSlot?: React.ReactNode;
}>;

const ProductListItem = (props: ProductListItemProps) => {
  const { count, children, extraCellsSlot, image, outputSlot } = props;
  const productListConfig = useContext(ProductListConfigContext);
  const { showCount, showImage, showOutput } = productListConfig;
  return (
    <Table.Row className="candystripe">
      {showImage && (
        <Table.Cell collapsing verticalAlign="middle">
          {image && <Image src={`data:image/png;base64,${image}`} />}
        </Table.Cell>
      )}
      {showCount && (
        <Table.Cell collapsing align="right" verticalAlign="middle" italic>
          {count !== undefined && `${count} x`}
        </Table.Cell>
      )}
      <Table.Cell verticalAlign="middle">{children}</Table.Cell>
      {extraCellsSlot}
      {showOutput && (
        <Table.Cell collapsing minWidth={8} px={1} verticalAlign="middle">
          {outputSlot}
        </Table.Cell>
      )}
    </Table.Row>
  );
};

type ProductListCellProps = ComponentProps<typeof Table.Cell>;

const ProductListCell = (props: ProductListCellProps) => {
  // written this way to provide defaults but allow overrides if given explicitly
  return <Table.Cell verticalAlign="middle" {...props} />;
};

type ProductListOutputButtonProps = ComponentProps<typeof Button> & {
  canOutput?: boolean;
};

const ProductListOutputButton = (props: ProductListOutputButtonProps) => {
  // written this way to provide defaults but allow overrides if given explicitly
  return <Button fluid textAlign="center" {...props} />;
};

ProductList.Item = ProductListItem;
ProductList.Cell = ProductListCell;
ProductList.OutputButton = ProductListOutputButton;
