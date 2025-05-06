/**
 * @file
 * @copyright 2025
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { BooleanLike } from 'tgui-core/react';

// Interface for the main body of the module tree.
export interface ModuleTreeProps {
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
  module_variables: VariableProps[];
  remove_action: string;
}

// Interface for each name-value variable pair that a module possesses.
export interface VariableProps {
  name: string;
  tooltip: string;
  value_type: string;
  value: any;
  edit_action?: string;
  edit_tooltip?: string;
}

// The interface for a standard variable value.
export interface VarValueProps {
  value: string;
}

// The interface for a toggleable boolean variable value.
export interface VarToggleableProps {
  value: BooleanLike;
  action: string;
  arguments?: string[];
}

// The interface for a variable value that should perform a function when clicked.
export interface VarReferenceProps {
  title: string;
  tooltip: string;
  action: string;
  arguments?: string[];
}

// The interface for a list of reference variables.
export interface VarReferenceListProps {
  variable_list: VarReferenceProps[];
}
