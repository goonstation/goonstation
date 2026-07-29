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
  onAction: Act;
  variables: VariableProps[];
}

export interface VariableProps {
  className?: string | BooleanLike;
  onAction: Act;
  name: string;
  tooltip: string;
  value_type: string;
  value: any;
  edit_action?: [string, object | undefined];
  edit_tooltip?: string;
}

export interface VarValueParent {
  onAction: Act;
}
