/**
 * @file
 * @copyright 2024
 * @author mloccy (https://github.com/mloccy)
 * @license ISC
 */

import { SortDirection } from "../type";
import { SearchState, SortableTableHeaderConfig, SortableTableRowProps, SortState } from "./type";

export const onSortClick = (index: number, current: SortState, setCallback: (nextState: SortState) => void) => {
  if (current !== null) {
    if (current.index === index) {
      setCallback({
        dir: (current.dir === SortDirection.Asc ? SortDirection.Desc : SortDirection.Asc),
        index: index,
      });
    } else {
      setCallback({ dir: SortDirection.Asc, index: index });
    }
  } else {
    setCallback({ dir: SortDirection.Asc, index: index });
  }
};

export const sortAndFilterRows = (
  headerConfig: SortableTableHeaderConfig[],
  rowConfig: SortableTableRowProps[],
  sortState: SortState,
  searchState: SearchState): SortableTableRowProps[] => {

  const first = rowConfig[0];
  let sorted = rowConfig;
  if (headerConfig.length !== first.cells.length) {
    throw new Error(`Inconsistent number of fields in table: ${headerConfig.length}x${first.cells.length}`);
  }

  let header: SortableTableHeaderConfig;

  if (sortState) {
    header = headerConfig[sortState.index];
  } else if (searchState) {
    header = headerConfig[searchState.index];
  } else {
    return rowConfig;
  }

  if (sortState && header.sortable) {
    const sortFunc = header.compareFunc;
    sorted = [...rowConfig].sort((rowA, rowB) => {

      const dataA = rowA.cells[sortState.index].data;
      const dataB = rowB.cells[sortState.index].data;

      return sortFunc(dataA, dataB);
    });

    if (sortState.dir === SortDirection.Asc) {
      sorted.reverse();
    }
  }

  if (searchState && header.searchable) {
    sorted = sorted.filter(val => {
      const data = val.cells[searchState.index].data;
      return header.toString(data).toLocaleLowerCase().includes(searchState.text.toLocaleLowerCase());
    });
  }

  return sorted;

};
