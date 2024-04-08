/**
 * @file
 * @copyright 2024
 * @author mloccy (https://github.com/mloccy)
 * @license ISC
 */

import { BooleanLike } from "common/react";
import { InfernoNode } from "inferno";
import { SortDirection } from "../type";

/** Configuration for Sortable Table header row and callback functions */
export interface SortableTableHeaderConfig {
  /** Presentation of header cell for this field */
  children: InfernoNode,

  /** Is this field sortable? */
  sortable: BooleanLike,

  /** Is this field searchable */
  searchable: BooleanLike,

  /** Callback function to sort on type specific to data given */
  compareFunc?: (a: unknown, b: unknown) => number,

  /** Conversion from your data to string to allow searching */
  toString?: (data: unknown) => string
}

export type SortState = {
  /** Index into SortableTableHeaderConfig */
  index: number,

  /** Direction to sort in */
  dir: SortDirection
}

/** Data required for searching through rows */
export type SearchState = {
  /** Index into SortableTableHeaderConfig */
  index: number

  /** Search text */
  text: string
}

interface SortableTableCellProps {
  /** Data used for sorting and searching */
  data: unknown,

  /** Presentation of data */
  children: InfernoNode,

  /** Does this data needed to be wrapped in a <Table.Cell>? Default: true */
  wrapInCell?: BooleanLike,

  /** Props, if provided to be spread on <Table.Cell> element */
  [x: keyof any]: unknown
}

export interface SortableTableRowProps {
  /** Table cells */
  cells: SortableTableCellProps[],

  /** Props, if provided to be spread on <Table.Row> element */
  [x: keyof any]: unknown
}
