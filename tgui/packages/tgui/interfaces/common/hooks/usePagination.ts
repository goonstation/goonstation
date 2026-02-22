/**
 * @file
 * @copyright 2025
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useCallback, useEffect, useMemo, useState } from 'react';
import { clamp } from 'tgui-core/math';

export const usePagination = <T>(
  items: T[],
  options?: { pageSize?: number; initialPage?: number },
) => {
  const { pageSize = 10, initialPage = 0 } = options ?? {};
  const numPages = Math.max(1, Math.ceil(items.length / pageSize));
  const [page, setPage] = useState(clamp(initialPage, 0, numPages - 1));
  const paginatedItems = useMemo(
    () => items.slice(page * pageSize, (page + 1) * pageSize),
    [items, page, pageSize],
  );
  const changePage = useCallback(
    (newPage: number) => setPage(clamp(newPage, 0, numPages - 1)),
    [numPages],
  );
  const incrementPage = useCallback(
    () => setPage((currentPage) => Math.min(currentPage + 1, numPages - 1)),
    [numPages],
  );
  const decrementPage = useCallback(
    () => setPage((currentPage) => Math.max(currentPage - 1, 0)),
    [],
  );
  // clamp page if out of bounds, e.g. by items being reduced while on last page
  useEffect(() => {
    if (page > numPages - 1) {
      setPage(numPages - 1);
    }
  }, [page, numPages]);
  return {
    canDecrementPage: page > 0,
    canIncrementPage: page < numPages - 1,
    changePage,
    decrementPage,
    incrementPage,
    items: paginatedItems,
    numPages,
    page,
  };
};
