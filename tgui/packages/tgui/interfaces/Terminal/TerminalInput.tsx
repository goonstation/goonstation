/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC
 */

import { KEY } from 'common/keys';
import { ComponentProps, KeyboardEventHandler, useCallback } from 'react';
import { Input } from 'tgui-core/components';

interface TerminalInputProps extends ComponentProps<typeof Input> {
  onUpPressed: (e: React.KeyboardEvent, value: KEY) => void;
  onDownPressed: (e: React.KeyboardEvent, value: KEY) => void;
}

export const TerminalInput = (props: TerminalInputProps) => {
  const { onUpPressed, onDownPressed, onKeyDown, ...rest } = props;

  const checkArrows: KeyboardEventHandler<HTMLInputElement> = useCallback(
    (e) => {
      const e_value = e.key;
      if (e_value === KEY.Up) {
        onUpPressed?.(e, e_value);
      } else if (e_value === KEY.Down) {
        onDownPressed?.(e, e_value);
      }
      onKeyDown?.(e);
    },
    [onDownPressed, onUpPressed],
  );

  return <Input onKeyDown={checkArrows} {...rest} />;
};
