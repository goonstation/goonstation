/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC
 */

import { KEY } from 'common/keys';
import { KeyboardEventHandler, useCallback } from 'react';
import { Input } from 'tgui-core/components';

export const TerminalInput = (props) => {
  const { onKeyUp, onKeyDown, onKey, ...rest } = props;

  const checkArrows: KeyboardEventHandler = useCallback(
    (e) => {
      const e_value = e.key;
      if (e_value === KEY.Up) {
        onKeyUp?.(e, e_value);
      } else if (e_value === KEY.Down) {
        onKeyDown?.(e, e_value);
      } else {
        onKey?.(e, e_value);
      }
    },
    [onKey, onKeyDown, onKeyUp],
  );

  return <Input onKeyDown={checkArrows} {...rest} />;
};
