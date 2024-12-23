/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

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

interface ItemActionPayload {
  itemRef: string;
}

export interface ModuleActionPayload extends ItemActionPayload {}

export interface ToolActionPayload extends ItemActionPayload {}

export interface MoveToolActionPayload extends ToolActionPayload {
  dir: Direction;
}

export interface ResetModuleActionPayload {
  moduleId: string;
}
