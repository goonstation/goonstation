/**
 * @file
 * @copyright 2025
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { PropsWithChildren, useMemo } from 'react';
import { Button, Stack } from 'tgui-core/components';

import { DiskDriveContext } from './context';
import { Disk } from './Disk';
import { DiskSlot } from './DiskSlot';

const DRIVE_HEIGHT = 2;

interface DiskDriveProps {
  // if not provided, behavior will default to onEject/onInsert based on whether a disk is inserted or not
  onDiskClick?: () => void;
  //
  onEject: () => void;
  onInsert: () => void;
}

export function DiskDrive(props: PropsWithChildren<DiskDriveProps>) {
  const { children, onDiskClick, onEject, onInsert } = props;
  const hasDisk = !!children;
  const diskDriveContextValue = useMemo(
    () => ({ onDiskClick: onDiskClick ?? (hasDisk ? onEject : onInsert) }),
    [onDiskClick, onEject],
  );
  return (
    <DiskDriveContext value={diskDriveContextValue}>
      <Stack height={DRIVE_HEIGHT}>
        <Stack.Item>
          <Button
            icon="eject"
            disabled={!hasDisk}
            onClick={onEject}
            tooltip={hasDisk ? 'Eject' : 'Nothing to eject'}
            height="100%"
            verticalAlignContent="middle"
          />
        </Stack.Item>
        <Stack.Item width={22}>
          {children || <DiskSlot onClick={onInsert} />}
        </Stack.Item>
      </Stack>
    </DiskDriveContext>
  );
}

DiskDrive.Disk = Disk;
