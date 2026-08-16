/**
 * @file
 * @copyright 2025
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { createContext } from 'react';

import { type DriveContextType } from './type';

const defaultDriveContext: DriveContextType = {
  onContentClick: undefined,
};

export const DriveContext = createContext(defaultDriveContext);
