import type { BanResource } from '../apiType';
import { ColumnConfig } from './Cell';
import dayjs from 'dayjs';
import duration from 'dayjs/plugin/duration';
import relativeTime from 'dayjs/plugin/relativeTime';
import { Box } from '../../../components';

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
      if (data.expires_at === null) {
        return 'Permanent';
      }
      const created_at = dayjs(data.created_at);
      const expires_at = dayjs(data.expires_at);
      const duration = dayjs.duration(created_at.diff(expires_at));
      return duration.humanize();
    },
    getValueTooltip: (data) => {
      const createdAtDate = dayjs(data.created_at);
      const expiresAtDate = dayjs(data.expires_at);
      const isDeleted = data.deleted_at !== null;

      // Banned Date
      let expirationText = [<>{createdAtDate.format('[Banned  ] YYYY-MM-DD HH:mm [UTC]\n')}</>];

      // Expiration Date
      if (data.expires_at === null) { // Permanent
        expirationText.push(<strong>Permanent</strong>);
      } else {
        expirationText.push(<>{expiresAtDate.format('[Expires ] YYYY-MM-DD HH:mm [UTC]')}</>);
      }

      // Deletion Date
      if (isDeleted) {
        expirationText.push(<>{dayjs(data.deleted_at).format('\n[Deleted ] YYYY-MM-DD HH:mm [UTC]')}</>);
      }
      return <pre>{expirationText}</pre>;
    },
    renderContents: (options: { data: BanResource; value: unknown }) => {
      const isNotActive = options.data.deleted_at !== null;
      if (isNotActive) {
        return <s>{options.value}</s>;
      }
      const isPermanent = options.data.expires_at === null;
      if (isPermanent) {
        return <strong>{options.value}</strong>;
      }
      return <Box>{options.value}</Box>;
    },
    basis: 7,
  },
  {
    header: 'Server',
    id: 'server',
    getValue: (data) => data.server_id ?? 'All',
    basis: 4,
  },
  {
    header: 'Admin',
    id: 'admin',
    getValue: (data) => data.game_admin.name,
    getValueTooltip: (data) => {
      return `${data.game_admin.ckey} (${data.game_admin_id})`;
    },
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
