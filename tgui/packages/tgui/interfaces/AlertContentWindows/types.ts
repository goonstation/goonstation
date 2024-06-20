/**
 * @file
 * @copyright 2023
 * @author garash2k
 * @license ISC
 */
import { InfernoNode } from 'inferno';

export type AlertContentWindow = {
  width?: number, // Default to 600
  height?: number, // Defaults to 480
  title: string,
  content: InfernoNode
};
