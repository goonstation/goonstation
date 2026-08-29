/**
 * @file
 * @copyright 2025
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { PropsWithChildren, useMemo } from 'react';
import { Button, Stack } from 'tgui-core/components';

import { DriveContext } from '../context';
import type { DriveBaseProps, DriveSlotProps } from '../type';
import { DriveSlot } from './DriveSlot';

const DRIVE_HEIGHT = 2;

interface DriveProps extends DriveBaseProps {
  slotComponent?: React.ComponentType<DriveSlotProps>;
}

export function Drive(props: PropsWithChildren<DriveProps>) {
  const {
    children,
    onContentClick,
    onEject,
    onInsert,
    slotComponent: SlotComponent = DriveSlot,
  } = props;
  const hasContent = !!children;
  const driveContextValue = useMemo(
    () => ({
      onContentClick: onContentClick ?? (hasContent ? onEject : onInsert),
    }),
    [hasContent, onContentClick, onEject],
  );
  return (
    <DriveContext value={driveContextValue}>
      <Stack height={DRIVE_HEIGHT}>
        <Stack.Item>
          <Button
            icon="eject"
            disabled={!hasContent}
            onClick={onEject}
            tooltip={hasContent ? 'Eject' : 'Nothing to eject'}
            height="100%"
            verticalAlignContent="middle"
          />
        </Stack.Item>
        <Stack.Item width={22}>
          {children || <SlotComponent onClick={onInsert} />}
        </Stack.Item>
      </Stack>
    </DriveContext>
  );
}

export { DriveContext };
