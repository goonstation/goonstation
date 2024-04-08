/**
 * @file
 * @copyright 2024
 * @author mloccy (https://github.com/mloccy)
 * @license MIT
 */

export const numericCompare = (a: number, b: number): number => a - b;

export const stringCompare = (a: string, b: string): number => {
  return a.localeCompare(b);
};
