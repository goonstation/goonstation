import { BooleanLike } from 'common/react';

import { ButtonProps } from '../../components/Button';

export interface DiskRackData {
  disks: Disk[];
  has_lights: BooleanLike;
}

export interface Disk {
  name: string;
  color: string;
  light: BooleanLike;
}

export type DiskButtonProps = Partial<{
  index: number;
}> &
  ButtonProps;
