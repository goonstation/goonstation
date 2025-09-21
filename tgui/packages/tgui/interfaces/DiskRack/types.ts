/**
 * @file
 * @copyright 2025
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @license MIT
 */

import type { BooleanLike } from 'common/react';

export interface DiskRackData {
  disks: Disk[];
  has_lights: BooleanLike;
}

export interface Disk {
  name: string;
  color: string;
  light: BooleanLike;
}
