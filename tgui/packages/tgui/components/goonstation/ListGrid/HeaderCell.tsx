import { Stack } from 'tgui-core/components';

import type { ColumnConfig } from './type';

export interface HeaderCellProps<T extends object, V> {
  config: ColumnConfig<T, V>;
}

export const HeaderCell = <T extends object, V>(
  props: HeaderCellProps<T, V>,
) => {
  const { config } = props;
  const { basis, grow, header } = config;
  return (
    <Stack.Item basis={basis} grow={grow} bold>
      {header}
    </Stack.Item>
  );
};
