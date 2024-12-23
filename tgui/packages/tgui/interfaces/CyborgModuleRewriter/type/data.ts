/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

export interface CyborgModuleRewriterData {
  modules: ModulesData;
}

interface AvailableModuleData {
  name: string;
  item_ref: string;
}

interface SelectedModuleData {
  item_ref: string;
  tools: Array<ToolData>;
}

export interface ModulesData {
  available: Array<AvailableModuleData>;
  selected: SelectedModuleData;
}

export interface ToolData {
  name: string;
  item_ref: string;
}
