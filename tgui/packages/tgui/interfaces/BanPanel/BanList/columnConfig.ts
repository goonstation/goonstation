import type { BanResource } from '../apiType';
import { ColumnConfig } from './Cell';
import dayjs from 'dayjs';
import duration from 'dayjs/plugin/duration';
import relativeTime from 'dayjs/plugin/relativeTime';

dayjs.extend(duration);
dayjs.extend(relativeTime);

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
    header: 'Duration',
    id: 'duration',
    getValue: (data) => {
      const created_at = dayjs(data.created_at);
      const expires_at = dayjs(data.expires_at);
      const duration = dayjs.duration(created_at.diff(expires_at));
      return duration.humanize();
    },
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
