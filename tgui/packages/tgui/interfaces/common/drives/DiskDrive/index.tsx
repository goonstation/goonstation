/**
 * @file
 * @copyright 2025
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { PropsWithChildren } from 'react';

import { Drive } from '../Drive';
import type { DriveBaseProps } from '../type';
import { Disk } from './Disk';

interface DiskDriveProps extends DriveBaseProps {}

export function DiskDrive(props: PropsWithChildren<DiskDriveProps>) {
  return <Drive {...props} />;
}

DiskDrive.Disk = Disk;
