import { BooleanLike } from 'common/react';

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
  game_admin?: {
    id: number;
    ckey: string;
    name: string;
  };
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
  // TODO
}

interface GameRoundResource {
  // TODO
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
