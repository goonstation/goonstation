/**
 * @file
 * @copyright 2025
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { BooleanLike } from 'tgui-core/react';

import { VariableProps } from '../../components/goonstation/VariableList/type';

// Interface for the main body of the module tree.
export interface SpeechModuleTreeProps {
  title: string;
  info: string;
  atom_ref: string;
  variables: VariableProps[];
  module_sections: ModuleSectionProps[];
}

// Interface for each section containing modules.
export interface ModuleSectionProps {
  title: string;
  modules: ModuleProps[];
  add_action: string;
}

// Interface for each individual module.
export interface ModuleProps {
  id: string;
  auxiliary: BooleanLike;
  atom_ref?: string;
  aux_ref?: string;
  module_variables: VariableProps[];
  remove_action: string;
}
