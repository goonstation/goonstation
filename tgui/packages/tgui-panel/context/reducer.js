/**
 * @file
 * @copyright 2023
 * @author Cheffie
 * @link https://github.com/CheffieGithub
 * @license MIT
 */

import { setContextFlags, setContextName, setContextTarget } from './actions';

const initialState = {
  contextTarget: null,
  contextFlags: null,
  contextName: null,
};

export const contextReducer = (state = initialState, action) => {
  const { type, payload, meta } = action;
  if (type === setContextTarget.type) {
    return {
      ...state,
      contextTarget: payload,
    };
  }
  if (type === setContextFlags.type) {
    return {
      ...state,
      contextFlags: payload,
    };
  }
  if (type === setContextName.type) {
    return {
      ...state,
      contextName: payload,
    };
  }
  return state;
};
