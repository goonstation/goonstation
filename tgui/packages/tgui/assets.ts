/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const loadedMappings: Record<string, string> = {};

export function resolveAsset(name: string): string {
  return loadedMappings[name] || name;
}
