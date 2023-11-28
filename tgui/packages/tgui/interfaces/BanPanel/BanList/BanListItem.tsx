/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Stack } from '../../../components';
import { BanResource } from '../apiType';
import { Cell, ColumnConfig } from './Cell';

interface BanListItemProps {
  columnConfigs: ColumnConfig<BanResource>[];
  data: BanResource;
  handleEditBan: (_e, id: number) => void;
  handleDeleteBan: (_e, id: number) => void;
}

export const BanListItem = (props: BanListItemProps) => {
  const { columnConfigs, data, handleEditBan, handleDeleteBan } = props;
  return (
    <Stack.Item className="BanListItem">
      <Stack>
        {columnConfigs.map((columnConfig) => (
          <Cell key={columnConfig.id} config={columnConfig} data={data} />
        ))}
      </Stack>
    </Stack.Item>
  );
};
