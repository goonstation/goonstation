import type { BooleanLike } from 'tgui-core/react';

import { sendAct } from '../../backend';
import type { Sort, SortProps } from './type';

export function getSortFromData(
  sortBy: string | null,
  sortAsc: BooleanLike,
): Sort | null {
  if (!sortBy || sortAsc === null || sortAsc === undefined) {
    return null;
  }
  return {
    sortBy,
    sortAsc: !!sortAsc,
  };
}

export const createSortPropsBuilder =
  (act: typeof sendAct, currentSort: Sort | null) =>
  (field: string): SortProps => ({
    onSort: () =>
      act('sort', {
        sortBy: field,
        asc: currentSort?.sortBy === field ? !currentSort.sortAsc : true,
      }),
    sortAsc: currentSort?.sortBy === field ? currentSort?.sortAsc : null,
  });

export const isNonNull = <T>(x: T | null): x is T => x !== null;
