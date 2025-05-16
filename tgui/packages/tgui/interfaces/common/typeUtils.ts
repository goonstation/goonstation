/**
 * @file
 * @copyright 2025
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

export type MapRecord<T, N> = {
  [U in keyof T]: N;
};

export type MapNever<T> = {
  [U in keyof T]?: never;
};
