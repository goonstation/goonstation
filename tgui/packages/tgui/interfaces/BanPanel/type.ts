/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */

import type { BanResource, PaginationMetaData } from './apiType';

interface BanPanelBaseData {
  current_tab: BanPanelTab;
}

interface PaginatedSearchResponse<T> {
  data: T[];
  links: unknown;
  meta: PaginationMetaData;
}

interface BanListData {
  search_response: PaginatedSearchResponse<BanResource> | null;
}

export interface BanListTabData extends BanPanelBaseData {
  current_tab: BanPanelTab.BanList;
  ban_list: BanListData;
  per_page: number;
}

interface JobBanListTabData extends BanPanelBaseData {
  current_tab: BanPanelTab.JobBanList;
}

export type BanPanelData = BanListTabData | JobBanListTabData;

// sync with code/modules/admin/ban_panel.dm BAN_PANEL_TAB defines
export enum BanPanelTab {
  BanList = 'ban_list',
  JobBanList = 'job_ban_list',
}

// sync with code/modules/admin/ban_panel.dm BAN_PANEL_ACTION defines
export enum BanPanelAction {
  SearchBans = 'ban_search',
  NavigatePreviousPage = 'page_prev',
  NavigateNextPage = 'page_next',
  SetPerPage = 'set_perpage',
  SetTab = 'set_tab',
  EditBan = 'edit_ban',
  DeleteBan = 'delete_ban',
}

// Options to filter by
export enum BanPanelSearchFilter {
  ID = 'id',
  ckey = 'ckey',
  og_ckey = 'original_ban_ckey',
  Server = 'server',
  Admin = 'admin_ckey',
  Reason = 'reason',
  CID = 'comp_id',
  IP_Address = 'ip',
}
