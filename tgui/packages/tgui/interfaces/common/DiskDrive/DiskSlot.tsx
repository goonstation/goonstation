/**
 * @file
 * @copyright 2025
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { Button } from 'tgui-core/components';

interface DiskSlotProps {
  onClick?: () => void;
}

export function DiskSlot(props: DiskSlotProps) {
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
