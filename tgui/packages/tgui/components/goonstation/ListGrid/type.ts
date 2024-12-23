import type { ReactNode } from 'react';

export type RowId = string;

interface ValuedColumnConfig<T extends object, V> {
  getValue: (data: T) => V;
  renderContents?: (options: {
    data: T;
    rowId: RowId;
    value: V | unknown;
  }) => ReactNode;
}
type ValuelessColumnConfig<T extends object> = {
  renderContents: (options: { data: T; rowId: RowId }) => ReactNode;
};
type ValueColumnConfig<T extends object, V> =
  | ValuedColumnConfig<T, V>
  | ValuelessColumnConfig<T>;

export const isValuedColumnConfig = <T extends object, V>(
  config: ValueColumnConfig<T, V>,
): config is ValuedColumnConfig<T, V> => 'getValue' in config;

interface CoreColumnConfig<T extends object> {
  id: string;
  getValueTooltip?: (data: T) => ReactNode;
  header: string;
}

interface LayoutColumnConfig {
  basis?: number;
  grow?: number | boolean;
}

export type ColumnConfig<T extends object, V = unknown> = CoreColumnConfig<T> &
  ValueColumnConfig<T, V> &
  LayoutColumnConfig;
