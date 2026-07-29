/**
 * @file
 * @copyright 2026
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { Button, Tooltip } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { ValueDisplayParent } from './type';

interface DisplayToggleableProps extends ValueDisplayParent {
  value: BooleanLike;
  action: [string, object | undefined];
}

/** Component for a toggleable boolean variable value. */
export const DisplayToggleable = (props: DisplayToggleableProps) => {
  return (
    <Tooltip content="Toggle Value">
      <Button
        onClick={() => props.onAction(...props.action)}
        color={props.value ? 'green' : 'red'}
      >
        {props.value ? 'TRUE' : 'FALSE'}
      </Button>
    </Tooltip>
  );
};
