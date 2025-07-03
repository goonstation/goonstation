/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Stack } from 'tgui-core/components';

import { Cell, ColumnConfig } from '../../../components/goonstation/ListGrid';
import { BanResource } from '../apiType';

interface BanListItemProps {
  columnConfigs: ColumnConfig<BanResource>[];
  data: BanResource;
  rowId: string;
}

export const BanListItem = (props: BanListItemProps) => {
  const { columnConfigs, data, rowId } = props;
  return (
    <Stack.Item>
      <Stack>
        {columnConfigs.map((columnConfig) => (
          <Cell
            key={columnConfig.id}
            columnConfig={columnConfig}
            data={data}
            rowId={rowId}
          />
        ))}
      </Stack>
    </Stack.Item>
  );
};
