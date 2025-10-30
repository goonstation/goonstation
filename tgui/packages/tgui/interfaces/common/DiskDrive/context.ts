/**
 * @file
 * @copyright 2025
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { createContext } from 'react';

interface DiskDriveContextType {
  onDiskClick?: () => void;
}

const defaultDiskDriveContext: DiskDriveContextType = {
  onDiskClick: undefined,
};

export const DiskDriveContext = createContext(defaultDiskDriveContext);
