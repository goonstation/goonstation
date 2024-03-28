/**
 * @file
 * @copyright 2023
 * @author Cheffie
 * @link https://github.com/CheffieGithub
 * @license MIT
 */

import { createAction } from 'common/redux';

export const setContextFlags = createAction('context/setFlags');
export const setContextTarget = createAction('context/setTarget');
export const setContextName = createAction('context/setName');
export const contextAct = createAction('context/act');
