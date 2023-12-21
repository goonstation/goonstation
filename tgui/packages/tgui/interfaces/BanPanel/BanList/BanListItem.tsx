/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Stack } from '../../../components';
import { BanResource } from '../apiType';
import { Cell, ColumnConfig } from '../../../components/goonstation/ListGrid';

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
          <Cell key={columnConfig.id} columnConfig={columnConfig} data={data} rowId={rowId} />
        ))}
      </Stack>
    </Stack.Item>
  );
};
