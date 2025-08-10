import { BooleanLike } from 'common/react';

export interface DiskRackData {
  disks: Disk[];
  has_lights: BooleanLike;
}

export interface Disk {
  name: string;
  color: string;
  light: BooleanLike;
}

export type DiskButtonProps = {
  index?: number;
  diskName?: string;
  diskColor?: string;
};
