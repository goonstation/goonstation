export type ComparatorFn<T> = (a: T, b: T) => number;
export const stringComparator = (a: string, b: string) => (a ?? '').localeCompare(b ?? '');
export const numberComparator = (a: number, b: number) => a - b;

export const buildFieldComparator
  = <T, V>(fieldFn: (stockItem: T) => V, comparatorFn: ComparatorFn<V>) =>
    (a: T, b: T) =>
      comparatorFn(fieldFn(a), fieldFn(b));
