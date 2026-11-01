/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { BooleanLike } from 'tgui-core/react';

export interface BanResource {
  id: number;
  round_id: number | null;
  game_admin_id: number | null;
  server_id: string | null;
  reason: string;
  duration: string;
  expires_at: string | null;
  created_at: string;
  updated_at: string | null;
  deleted_at: string | null;
  game_admin?: GameAdmin;
  game_round?: GameRoundResource;
  original_ban_detail?: {
    id: number;
    ban_id: number;
    ckey: string;
    comp_id: string;
    ip: string;
  };
  details: BanDetailResource[];
  requires_appeal: BooleanLike;
}

interface BanDetailResource {
  id: number;
  ban_id: number;
  ckey: string | null;
  comp_id: string | null;
  ip: string | null;
  created_at: string | null;
  updated_at: string | null;
  deleted_at: string | null;
}

interface GameRoundResource {
  id: number;
  server_id: string | null;
  map: string | null;
  game_type: string | null;
  rp_mode: boolean;
  crashed: boolean;
  ended_at: string | null;
  created_at: string | null;
  updated_at: string | null;
}

export interface JobBanResource {
  id: number;
  round_id: number | null;
  game_admin_id: number | null;
  server_id: string | null;
  ckey: string;
  banned_from_job: string;
  reason: string;
  expires_at: string | null;
  created_at: string;
  updated_at: string | null;
  deleted_at: string | null;
  game_admin?: GameAdmin;
}

export interface GameAdmin {
  id: number;
  ckey: string;
  name: string;
}

export interface PaginationMetaData {
  current_page: number;
  from: number;
  last_page: number;
  links: unknown;
  path: string;
  per_page: number;
  to: number;
  total: number;
}
