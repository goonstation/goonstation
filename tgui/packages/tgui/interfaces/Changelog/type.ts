/**
 * @file
 * @copyright 2026
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license ISC
 */

import { BooleanLike } from 'common/react';

export enum ChangelogTabKeys {
  Changes,
  Admin,
  Attribution,
}

export interface ChangelogData {
  entries: DateEntryData[];
  is_admin: BooleanLike;
  admin_entries: DateEntryData[];
  current_commit: string;
  dev_host: string;
  dev_coders: string;
  dev_spriters: string;
}

export interface HeaderData {
  current_commit: string;
  setTab;
}

export interface DateEntryData {
  entry_date: string;
  major_entries: ChangeEntryData[];
  minor_entries: ChangeEntryData[];
}

export interface ChangeEntryData {
  author: string;
  pr_num: string | null;
  feedback: string | null;
  emojis: string | null;
  emoji_tooltips: string | null;
  changes: string[];
  top_entry: boolean;
}
