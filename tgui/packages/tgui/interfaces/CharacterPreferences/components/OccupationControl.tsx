/**
 * @file
 * @copyright 2025
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { PropsWithChildren, useCallback, useMemo } from 'react';
import { Box, Button, Stack } from 'tgui-core/components';

import { PriorityLevel } from '../type';

interface OccupationControlProps {
  color?: string;
  disabled?: boolean;
  hasWikiLink?: boolean;
  onChangePriorityLevel: (newPriorityLevel: number) => void;
  onMenuOpen: () => void;
  priorityLevel: number;
  required?: boolean;
  tooltip?: React.ReactNode;
}

export function OccupationControl(
  props: PropsWithChildren<OccupationControlProps>,
) {
  const {
    children,
    color,
    disabled,
    onChangePriorityLevel,
    onMenuOpen,
    priorityLevel,
    required,
    tooltip,
  } = props;
  const handleIncreasePriorityLevel = useCallback(
    () =>
      priorityLevel > PriorityLevel.Favorite &&
      onChangePriorityLevel(priorityLevel - 1),
    [onChangePriorityLevel, priorityLevel],
  );
  const handleDecreasePriorityLevel = useCallback(
    () =>
      priorityLevel < PriorityLevel.Unwanted &&
      onChangePriorityLevel(priorityLevel + 1),
    [onChangePriorityLevel, priorityLevel],
  );
  const decreaseButtonProps = useMemo(
    () => getDecreaseButtonProps(!!disabled, priorityLevel, !!required),
    [disabled, priorityLevel, required],
  );
  return (
    <Stack g={0.5}>
      <Stack.Item>
        <Button
          color={color}
          disabled={disabled || priorityLevel === PriorityLevel.Favorite}
          icon="chevron-left"
          onClick={handleIncreasePriorityLevel}
          tooltip={!disabled ? 'Increase Priority' : undefined}
        />
      </Stack.Item>
      <Stack.Item grow minWidth="0px">
        <Button
          fluid
          textAlign="center"
          color={color}
          disabled={disabled}
          onClick={onMenuOpen}
          tooltip={tooltip}
        >
          {children}
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button
          color={color}
          icon="chevron-right"
          onClick={handleDecreasePriorityLevel}
          {...decreaseButtonProps}
        />
      </Stack.Item>
    </Stack>
  );
}

function getDecreaseButtonProps(
  disabled: boolean,
  priorityLevel: PriorityLevel,
  required: boolean,
) {
  if (disabled || priorityLevel === PriorityLevel.Unwanted) {
    return {
      disabled: true,
      tooltip: undefined,
    };
  }
  if (required && priorityLevel === PriorityLevel.Low) {
    return {
      disabled: true,
      tooltip: 'Cannot be set to Unwanted',
    };
  }
  return {
    disabled: false,
    tooltip: 'Decrease Priority',
  };
}

interface OccupationControlContentsProps {
  occupationName: string;
}

export function OccupationControlContents(
  props: OccupationControlContentsProps,
) {
  const { occupationName } = props;
  return occupationName === 'Clown' ? (
    <Box
      overflow="hidden"
      style={{
        fontFamily: 'Comic Sans MS',
        fontSize: '13px',
      }}
    >
      {occupationName}
    </Box>
  ) : (
    <Box overflow="hidden">{occupationName}</Box>
  );
}
