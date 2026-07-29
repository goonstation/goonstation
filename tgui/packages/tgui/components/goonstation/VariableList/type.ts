/**
 * @file
 * @copyright 2026
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { ComponentProps } from 'react';
import { BooleanLike } from 'tgui-core/react';

import { valueDisplayComponents } from './actions';

type Act = (action: string, payload?: object) => void;

type DisplayComponents = typeof valueDisplayComponents;
type DisplayKey = keyof DisplayComponents;
type DisplayProps = ComponentProps<DisplayComponents[DisplayKey]>;

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
  value_type: DisplayKey;
  value: DisplayProps;
  edit_action?: [string, object | undefined];
  edit_tooltip?: string;
}

export interface ValueDisplayParent {
  onAction: Act;
}
