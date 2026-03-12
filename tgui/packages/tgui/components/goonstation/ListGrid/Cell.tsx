/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */

import { ReactNode } from 'react';
import { Box, Stack, Tooltip } from 'tgui-core/components';

import { ColumnConfig, isValuedColumnConfig, RowId } from './type';

interface CellProps<T extends object, V> {
  columnConfig: ColumnConfig<T, V>;
  data: T;
  rowId: RowId;
}

export const Cell = <T extends object, V>(props: CellProps<T, V>) => {
  const { columnConfig: config, data, rowId } = props;
  const { basis, getValueTooltip, grow, renderContents } = config;
  const hasValue = isValuedColumnConfig(config);
  const value = hasValue ? config.getValue(data) : undefined;
  const tooltipText = getValueTooltip?.(data);
  const contents = renderContents ? (
    renderContents({ data, rowId, value })
  ) : (
    <Box>{value as ReactNode}</Box>
  );
  const cellContents = tooltipText ? (
    <Tooltip content={tooltipText}>{contents}</Tooltip>
  ) : (
    contents
  );
  return (
    <Stack.Item basis={basis} grow={grow}>
      {cellContents}
    </Stack.Item>
  );
};
