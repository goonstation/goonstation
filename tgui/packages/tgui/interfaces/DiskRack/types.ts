/**
 * @file
 * @copyright 2025
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @license MIT
 */

import type { BooleanLike } from 'common/react';

export interface DiskRackData {
  disk_slots: DiskSlot[];
  has_lights: BooleanLike;
  is_wide: BooleanLike;
}

export interface DiskSlot {
  litColor: string;
  unlitColor: string;
  disk: Disk;
}

export interface Disk {
  name: string;
  color: string;
  light: BooleanLike;
}
