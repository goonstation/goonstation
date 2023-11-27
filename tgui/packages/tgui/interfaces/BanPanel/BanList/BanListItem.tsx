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
}

export const BanListItem = (props: BanListItemProps) => {
  const { columnConfigs, data } = props;
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
