/**
 * @file
 * @copyright 2026
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { BooleanLike } from 'tgui-core/react';
import { ComponentProps } from 'react';

import { variableValueComponents } from './actions';

type Act = (action: string, payload?: object) => void;

type VarValueComponents = typeof variableValueComponents;
type VarValueKey = keyof VarValueComponents;
type VarValueProps = ComponentProps<VarValueComponents[VarValueKey]>;

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
  value_type: VarValueKey;
  value: VarValueProps;
  edit_action?: [string, object | undefined];
  edit_tooltip?: string;
}

export interface VarValueParent {
  onAction: Act;
}
