/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */

import dayjs from 'dayjs';
import duration from 'dayjs/plugin/duration';
import relativeTime from 'dayjs/plugin/relativeTime';
import { ReactNode } from 'react';
import { Button } from 'tgui-core/components';

import type { ColumnConfig } from '../../../components/goonstation/ListGrid';
import type { BanResource } from '../apiType';

dayjs.extend(duration);
dayjs.extend(relativeTime);

interface ColumnConfigsCallbacks {
  deleteBan: (id: number) => void;
  editBan: (id: number) => void;
}

export const buildColumnConfigs = (
  callbacks: ColumnConfigsCallbacks,
): ColumnConfig<BanResource>[] => [
  {
    header: '',
    id: 'actions',
    renderContents: ({ rowId }) => (
      <>
        <Button
          key="edit"
          icon="pencil"
          onClick={() => callbacks.editBan(rowId)}
        />
        <Button
          key="delete"
          icon="trash"
          onClick={() => callbacks.deleteBan(rowId)}
          color="red"
        />
      </>
    ),
    basis: 4.5,
  },
  {
    header: 'ID',
    id: 'id',
    getValue: (data) => data.id,
    renderContents: ({ value }) => (
      <a href={`https://goonhub.com/admin/bans/${value}`}>{value}</a>
    ),
    basis: 4,
  },
  {
    header: 'ckey',
    id: 'ckey',
    getValue: (data) => data.original_ban_detail?.ckey ?? 'N/A',
    renderContents: ({ value }) => (
      <a href={`https://goonhub.com/admin/players/${value}`}>{value}</a>
    ),
    basis: 10, // I think 32 chars is the max, this is slightly below but whatever
    grow: 1,
  },
  {
    header: 'Duration',
    id: 'duration',
    getValue: (data) => {
      if (data.expires_at === null) {
        if (data.requires_appeal) {
          return 'Until Appeal';
        }
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
      let tooltipText = [
        <>{createdAtDate.format('[Banned ] YYYY-MM-DD HH:mm [UTC]\n')}</>,
      ];

      // Expiration Date
      if (data.expires_at === null) {
        // Permanent
        tooltipText.push(<strong>Permanent</strong>);
      } else {
        const expiresAtDate = dayjs(data.expires_at);
        tooltipText.push(
          <>{expiresAtDate.format('[Expires] YYYY-MM-DD HH:mm [UTC]')}</>,
        );
      }

      // Deletion Date
      if (data.deleted_at !== null) {
        tooltipText.push(
          <>
            {dayjs(data.deleted_at).format(
              '\n[Deleted] YYYY-MM-DD HH:mm [UTC]',
            )}
          </>,
        );
      }
      return <pre>{tooltipText}</pre>;
    },
    renderContents: (options: { data: BanResource; value: unknown }) => {
      if (options.data.deleted_at !== null) {
        return (
          <div className="ExpiredBan BanText">{options.value as ReactNode}</div>
        );
      }
      return (
        <div className="CurrentBan BanText">{options.value as ReactNode}</div>
      );
    },
    basis: 7.5,
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
    getValue: (data) => data.game_admin ?? 'N/A',
    renderContents: ({ value }) => (
      <a
        href={`https://goonhub.com/admin/game-admins/${value.id}`}
        className="NoColor"
      >
        {value.name}
      </a>
    ),
    getValueTooltip: (data) => {
      if (data.game_admin === null) {
        return 'N/A';
      }
      return `${data.game_admin?.ckey} (${data.game_admin_id})`;
    },
    basis: 6.5,
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
    getValue: (data) => data.original_ban_detail?.comp_id ?? 'N/A',
    basis: 7,
  },
  {
    header: 'IP',
    id: 'ip',
    getValue: (data) => data.original_ban_detail?.ip ?? 'N/A',
    basis: 9,
  },
];
