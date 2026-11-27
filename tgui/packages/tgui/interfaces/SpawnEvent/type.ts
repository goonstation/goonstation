import { BooleanLike } from 'common/react';

export interface SpawnEventData {
  event_title: string;
  ghost_confirmation_delay: number;
  ask_permission: BooleanLike;
  allow_dnr: BooleanLike;
  eligible_player_count: number;
  roles: SpawnEventRoleData[];
}

export interface SpawnEventRoleData {
  ref: string;
  spawn_type: string;
  thing_to_spawn: string;
  thing_name: string;
  spawn_directly: BooleanLike;
  loc_type: string;
  spawn_loc: string;
  amount_to_spawn: number;
  antag_role: string;
  objective_text: string;
  job_wanted_location: string;
  incompatible_antag: BooleanLike;
  add_to_manifest: BooleanLike;
  equip_antag: BooleanLike;
  choose_name: BooleanLike;
  disable_choose_name: BooleanLike;
}
