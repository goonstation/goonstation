/**
 * @file
 * @copyright 2025
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { Button } from 'tgui-core/components';

import { type DriveSlotProps } from '../type';

export function DriveSlot(props: DriveSlotProps) {
  const { onClick } = props;
  return (
    <Button
      disabled={!onClick}
      fluid
      onClick={onClick}
      textAlign="center"
      height="100%"
      verticalAlignContent="middle"
    >
      Empty Slot
    </Button>
  );
}
