/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
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
  SetTab = 'set_tab',
}
