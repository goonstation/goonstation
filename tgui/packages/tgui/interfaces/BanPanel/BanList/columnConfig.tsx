/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */

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
    getValue: (data) => data.original_ban_detail.ckey ?? "N/A",
    basis: 10, // I think 32 chars is the max, this is slightly below but whatever
    grow: 1,
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

      // Banned Date
      const createdAtDate = dayjs(data.created_at);
      let tooltipText = [<>{createdAtDate.format('[Banned  ] YYYY-MM-DD HH:mm [UTC]\n')}</>];

      // Expiration Date
      if (data.expires_at === null) { // Permanent
        tooltipText.push(<strong>Permanent</strong>);
      } else {
        const expiresAtDate = dayjs(data.expires_at);
        tooltipText.push(<>{expiresAtDate.format('[Expires ] YYYY-MM-DD HH:mm [UTC]')}</>);
      }

      // Deletion Date
      if (data.deleted_at !== null) {
        tooltipText.push(<>{dayjs(data.deleted_at).format('\n[Deleted ] YYYY-MM-DD HH:mm [UTC]')}</>);
      }
      return <pre>{tooltipText}</pre>;
    },
    renderContents: (options: { data: BanResource; value: unknown }) => {
      if (options.data.deleted_at !== null) {
        return <div className="ExpiredBan">{options.value}</div>;
      }
      if (options.data.expires_at === null) {
        return <div className="CurrentBan PermaBan">{options.value}</div>;
      }
      return <div className="CurrentBan">{options.value}</div>;
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
    basis: 6,
  },
  {
    header: 'Reason',
    id: 'reason',
    getValue: (data) => data.reason,
    basis: 10,
    grow: 10,
  },
  {
    header: 'CID',
    id: 'cid',
    getValue: (data) => data.original_ban_detail.comp_id ?? "N/A",
    basis: 7,
  },
  {
    header: 'IP',
    id: 'ip',
    getValue: (data) => data.original_ban_detail.ip ?? "N/A",
    basis: 9,
  },
];
