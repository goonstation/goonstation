/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

export const block = (base: string, suffix: string) => `${base}-${suffix}`;

export const element = (block: string, element: string) => `${block}__${element}`;

export const modifier = (element: string, modifier: string) => `${element}--${modifier}`;
