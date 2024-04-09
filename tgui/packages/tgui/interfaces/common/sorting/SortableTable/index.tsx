/**
 * @file
 * @copyright 2024
 * @author mloccy (https://github.com/mloccy)
 * @license ISC
 */

import { BooleanLike } from "common/react";
import { Fragment } from "inferno";
import { useLocalState, useSharedState } from "../../../../backend";
import { Table, Tooltip } from "../../../../components";
import { Header } from "../Header";
import { SearchState, SortableTableHeaderConfig, SortableTableRowProps, SortState } from "./type";
import { onSortClick, sortAndFilterRows } from "./utils";


interface SortableTableHeaderRowProps {
  config: SortableTableHeaderConfig[],
  sortState: SortState,
  setSortBy: (index: number) => void
}

const SortableTableHeaderRow = (props: SortableTableHeaderRowProps) => {
  const { config, sortState, setSortBy } = props;

  return (
    <Table.Row header>
      {config.map((config, index: number) => {
        const { children, sortable, toolTipContent } = config;
        const needsHeader = sortable === undefined ? true : sortable;

        const sortDirection = !sortState
          ? null
          : index === sortState.index
            ? sortState.dir
            : null;
        const sortByIndex = () => setSortBy(index);


        if (toolTipContent) {
          if (needsHeader) {

            return (
              <Tooltip content={toolTipContent}>
                <Table.Cell header key={index}>
                  <Header sortDirection={sortDirection} onSortClick={sortByIndex}>{children}</Header>
                </Table.Cell>
              </Tooltip>);
          }
          else {
            return (
              <Tooltip content={toolTipContent}>
                <Table.Cell header key={index}>
                  {children}
                </Table.Cell>
              </Tooltip>);
          }
        } else {

          if (needsHeader) {
            return (
              <Table.Cell header key={index}>
                <Header sortDirection={sortDirection} onSortClick={sortByIndex}>{children}</Header>
              </Table.Cell>);
          } else {
            return (
              <Table.Cell header key={index}>
                {children}
              </Table.Cell>);

          }
        }
      })}
    </Table.Row>
  );
};

const SortableTableRow = (props: SortableTableRowProps) => {
  const { cells, ...rest } = props;
  return (

    <Table.Row
      {...rest}>
      {cells.map((config, index) => {
        const { children, wrapInCell, ...rest } = config;
        if (!children) {
          return;
        }
        let wrapCell = wrapInCell === undefined
          ? true
          : wrapInCell;

        if (wrapCell) {

          return (
            <Table.Cell
              key={index}
              {...rest}>
              {children}
            </Table.Cell>);
        } else {
          return (
            <Fragment
              key={index}
              {...rest}>
              {children}
            </Fragment>);
        }
      })}

    </Table.Row>);
};

interface SortableTableProps {
  /** Configure the header row of the table */
  headerConfig: SortableTableHeaderConfig[]

  /** Row data */
  rowData: SortableTableRowProps[],

  /** A name for the table for use with useLocalState / useSharedState */
  name: string,

  /** Use local state or shared state; Default: true */
  useLocalState?: BooleanLike,

  /** Data required for searching through rows */
  searchState?: SearchState

  /** Props, if provided to be spread on <Table> element */
  [x: keyof any]: unknown
}

/**
 * Sortable and searchable table component
 */
export const SortableTable = (props: SortableTableProps, context) => {
  const { headerConfig, rowData, sharedState, name, searchState, ...rest } = props;
  const stateFunc = useLocalState === undefined
    ? useLocalState
    : useLocalState
      ? useSharedState
      : useLocalState;

  const [sortState, setSortBy] = stateFunc<SortState>(context, `sortState_${name}`, null);

  return (
    <Table
      {...rest}>
      <SortableTableHeaderRow
        config={headerConfig}
        sortState={sortState}
        setSortBy={(index: number) => onSortClick(index, sortState, setSortBy)} />
      {
        sortAndFilterRows(headerConfig, rowData, sortState, searchState).map((rowConfig, index) => {
          const { cells, ...rest } = rowConfig;
          return (
            <SortableTableRow {...rest} key={index} cells={cells} />
          );
        })
      }
    </Table>);
};
