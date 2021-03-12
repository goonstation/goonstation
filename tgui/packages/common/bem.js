/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

export const block = (base, suffix) => `${base}-${suffix}`;

export const element = (block, element) => `${block}__${element}`;

export const modifier = (element, modifier) => `${element}--${modifier}`;
