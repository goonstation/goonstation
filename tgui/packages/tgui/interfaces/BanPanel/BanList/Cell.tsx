import { InfernoNode } from 'inferno';
import { Stack } from '../../../components';

interface CoreColumnConfig<T extends object, V> {
  id: string;
  getValue: (data: T) => V;
  header: string;
  renderContents?: (options: { data: T; value: V }) => InfernoNode;
}

interface LayoutColumnConfig {
  basis?: number;
  grow?: number | boolean;
}

export type ColumnConfig<T extends object, V = unknown> = CoreColumnConfig<T, V> & LayoutColumnConfig;

export interface CellProps<T extends object, V> {
  config: ColumnConfig<T, V>;
  data: T;
}

export const Cell = <T extends object, V>(props: CellProps<T, V>) => {
  const { config, data } = props;
  const { basis, getValue, grow, renderContents } = config;
  const value = getValue(data);
  const contents = renderContents ? renderContents({ data, value }) : value;
  return (
    <Stack.Item basis={basis} grow={grow}>
      {contents}
    </Stack.Item>
  );
};

export interface HeaderCellProps<T extends object, V> {
  config: ColumnConfig<T, V>;
}

export const HeaderCell = <T extends object, V>(props: HeaderCellProps<T, V>) => {
  const { config } = props;
  const { basis, grow, header } = config;
  return (
    <Stack.Item basis={basis} grow={grow} bold>
      {header}
    </Stack.Item>
  );
};
