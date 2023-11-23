import type { BanResource } from '../apiType';
import { ColumnConfig } from './Cell';

export const columnConfigs: ColumnConfig<BanResource>[] = [
  {
    header: 'ID',
    id: 'id',
    getValue: (data) => data.id,
    basis: 4,
  },
  {
    header: 'ckey',
    id: 'ckey',
    getValue: (data) => data.original_ban_detail.ckey,
    basis: 15, // I think 32 chars is the max, this is slightly below but whatever
  },
  {
    header: 'Time',
    id: 'time',
    getValue: (data) => data.expires_at,
    basis: 7,
  },
  {
    header: 'Server',
    id: 'server',
    getValue: (data) => data.server_id ?? "All",
    basis: 5,
  },
  {
    header: 'Admin',
    id: 'admin',
    getValue: (data) => data.game_admin.ckey,
    basis: 7,
  },
  {
    header: 'Reason',
    id: 'reason',
    getValue: (data) => data.reason,
    basis: 5,
    grow: 1,
  },
  {
    header: 'CID',
    id: 'cid',
    getValue: (data) => data.original_ban_detail.comp_id,
    basis: 7,
  },
  {
    header: 'IP',
    id: 'ip',
    getValue: (data) => data.original_ban_detail.ip,
    basis: 9,
  },
];
