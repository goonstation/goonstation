/**
 * @file
 * @copyright 2023
 * @author Cheffie
 * @link https://github.com/CheffieGithub
 * @license MIT
 */

import { useSelector } from 'common/redux';
import { selectContext } from './selectors';

export const useContext = context => {
  return useSelector(context, selectContext);
};

