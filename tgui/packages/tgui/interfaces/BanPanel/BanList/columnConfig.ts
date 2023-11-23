import type { BanResource } from '../apiType';
import { ColumnConfig } from './Cell';

export const columnConfigs: ColumnConfig<BanResource>[] = [
  {
    header: 'ID',
    id: 'id',
    getValue: (data) => data.id,
    basis: 5,
  },
  {
    header: 'Reason',
    id: 'reason',
    getValue: (data) => data.reason,
    basis: 5,
    grow: 1,
  },
];
