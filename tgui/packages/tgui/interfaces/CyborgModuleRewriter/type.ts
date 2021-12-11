/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

export interface CyborgModuleRewriterData {
  modules: ModulesData,
}

interface AvailableModule {
  name: string,
  ref: string,
}

interface SelectedModule {
  ref: string,
  tools: Array<ToolData>,
}

export interface ModulesData {
  available: Array<AvailableModule>,
  selected: SelectedModule,
}

export interface ToolData {
  name: string,
  ref: string,
}

export enum Action {
  EjectModule = 'module-eject',
  MoveTool = 'tool-move',
  RemoveTool = 'tool-remove',
  ResetModule = 'module-reset',
  SelectModule = 'module-select',
}

export enum Direction {
  Up = 'up',
  Down = 'down',
}

export type Act = (action: string, payload?: object) => void

export interface ModuleActionPayload {
  moduleRef: string,
}

export interface ToolActionPayload extends ModuleActionPayload {
  toolRef: string,
}

export interface MoveToolActionPayload extends ToolActionPayload {
  dir: Direction,
}

export interface ResetModuleActionPayload extends ModuleActionPayload {
  moduleId: string,
}
