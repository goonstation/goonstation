/**
 * @file
 * @copyright 2026
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { Button, Tooltip } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { VarValueParent } from './type';

interface VarToggleableProps extends VarValueParent {
  value: BooleanLike;
  action: [string, object | undefined];
}

/** Component for a toggleable boolean variable value. */
export const VariableToggleable = (props: VarToggleableProps) => {
  return (
    <Tooltip content="Toggle Value">
      <Button
        onClick={() => props.act(...props.action)}
        color={props.value ? 'green' : 'red'}
      >
        {props.value ? 'TRUE' : 'FALSE'}
      </Button>
    </Tooltip>
  );
};
