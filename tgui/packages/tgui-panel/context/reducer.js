/**
 * @file
 * @copyright 2023
 * @author Cheffie
 * @link https://github.com/CheffieGithub
 * @license MIT
 */

import { setContextFlags, setContextName, setContextTarget } from './actions';
import { createLogger } from 'tgui/logging';

const logger = createLogger('REDUCER');

const initialState = {
  contextTarget: null,
  contextFlags: null,
  contextName: null,
};

export const contextReducer = (state = initialState, action) => {
  const { type, payload, meta } = action;
  if (type === setContextTarget.type) {
    logger.log(payload);
    return {
      ...state,
      contextTarget: payload,
    };
  }
  if (type === setContextFlags.type) {
    logger.log(payload);
    return {
      ...state,
      contextFlags: payload,
    };
  }
  if (type === setContextName.type) {
    logger.log(payload);
    return {
      ...state,
      contextName: payload,
    };
  }
  return state;
};
