/**
 * @file
 * @copyright 2026
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { BooleanLike } from 'tgui-core/react';

import { VariableProps } from '../../components/goonstation/VariableList/type';

export interface AbstractSaySourcesProps {
  info: string;
  say_sources: AbstractSaySourceProps[];
}

export interface AbstractSaySourceProps {
  internal_name: string;
  admin_created: BooleanLike;
  atom_ref: string;
  atom_variables: VariableProps[];
  verb_variables: VariableProps[];
}
