/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import {
  Act,
  Action,
  ModuleActionPayload,
  MoveToolActionPayload,
  ResetModuleActionPayload,
  ToolActionPayload,
} from './type';

const createAction = <T extends object>(action: Action) => (act: Act, payload: T) => act(action, payload);

export const ejectModule = createAction<ModuleActionPayload>(Action.EjectModule);
export const moveTool = createAction<MoveToolActionPayload>(Action.MoveTool);
export const removeTool = createAction<ToolActionPayload>(Action.RemoveTool);
export const resetModule = createAction<ResetModuleActionPayload>(Action.ResetModule);
export const selectModule = createAction<ModuleActionPayload>(Action.SelectModule);
