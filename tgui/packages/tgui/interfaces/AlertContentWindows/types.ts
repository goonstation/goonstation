/**
 * @file
 * @copyright 2023
 * @author garash2k
 * @license ISC
 */
import React from 'react';

export type AlertContentWindow = {
  width?: number; // Default to 600
  height?: number; // Defaults to 480
  title?: string; // Defaults to Antagonist Tips
  content: React.ReactNode;
  theme?: string;
};
