/**
 * @file
 * @copyright 2022
 * @author Original Amylizzle (https://github.com/amylizzle)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { ComponentProps } from 'react';
import { Button, Table } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import type { MapNever } from '../common/typeUtils';
import type { SortProps } from './type';

const PlantmasterHeadingRow = (props: ComponentProps<typeof Table.Row>) => (
  <Table.Row {...props} />
);

function sortAscToIcon(sortAsc: boolean | null) {
  switch (sortAsc) {
    case true: {
      return 'angle-up';
    }
    case false: {
      return 'angle-down';
    }
    default: {
      return undefined;
    }
  }
}

type BasePlantmasterHeadingCellProps = ComponentProps<typeof Table.Cell> &
  Partial<SortProps>;
type SortablePlantmasterHeadingCellProps = BasePlantmasterHeadingCellProps &
  Required<SortProps>;
type UnsortablePlantmasterHeadingCellProps = BasePlantmasterHeadingCellProps &
  MapNever<SortProps>;

type PlantmasterHeadingCellProps =
  | SortablePlantmasterHeadingCellProps
  | UnsortablePlantmasterHeadingCellProps;

const PlantmasterHeadingCell = (props: PlantmasterHeadingCellProps) => {
  const { children, onSort, sortAsc, ...rest } = props;
  return (
    <Table.Cell header textAlign="center" {...rest}>
      {onSort ? (
        <Button
          color="transparent"
          icon={sortAscToIcon(sortAsc)}
          onClick={onSort}
        >
          {children}
        </Button>
      ) : (
        children
      )}
    </Table.Cell>
  );
};

const PlantmasterRow = (props: ComponentProps<typeof Table.Row>) => {
  const { className, ...rest } = props;
  const cn = classes([className, 'candystripe']);
  return <Table.Row className={cn} {...rest} />;
};

const PlantmasterCell = (
  props: ComponentProps<typeof Table.Cell> & { dominant?: boolean },
) => {
  const { dominant, ...rest } = props;
  return (
    <Table.Cell
      textAlign="center"
      verticalAlign="middle"
      bold={dominant}
      backgroundColor={dominant ? '#333333' : undefined}
      {...rest}
    />
  );
};

export const PlantmasterTable = (props: ComponentProps<typeof Table>) => (
  <Table {...props} />
);

PlantmasterTable.HeadingRow = PlantmasterHeadingRow;
PlantmasterTable.HeadingCell = PlantmasterHeadingCell;
PlantmasterTable.Row = PlantmasterRow;
PlantmasterTable.Cell = PlantmasterCell;
