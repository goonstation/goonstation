/**
 * @file
 * @copyright 2026
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { BooleanLike } from 'tgui-core/react';

type Act = (action: string, payload?: object) => void;

export interface VariableListProps {
  className?: string | BooleanLike;
  act: Act;
  variables: VariableProps[];
}

export interface VariableProps {
  className?: string | BooleanLike;
  act: Act;
  name: string;
  tooltip: string;
  value_type: string;
  value: any;
  edit_action?: [string, object | undefined];
  edit_tooltip?: string;
}

export interface VarValueParent {
  act: Act;
}
