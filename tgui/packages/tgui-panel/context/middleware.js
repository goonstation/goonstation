/**
 * @file
 * @copyright 2023
 * @author Cheffie
 * @link https://github.com/CheffieGithub
 * @license MIT
 */

import { setContextFlags, setContextName, setContextTarget } from "./actions";
import { chatRenderer } from '../chat/renderer';

export const contextMiddleware = store => {
  chatRenderer.events.on('contextAct', (flags, target, name) => {
    store.dispatch(setContextFlags(flags));
    store.dispatch(setContextTarget(target));
    store.dispatch(setContextName(name));
  });
  return next => action => {
    return next(action);
  };
};
