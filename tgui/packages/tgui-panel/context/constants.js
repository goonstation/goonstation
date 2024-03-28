/**
 * @file
 * @copyright 2023
 * @author Cheffie
 * @link https://github.com/CheffieGithub
 * @license MIT
 */

// Should match defines in admin/context_flags.dm
export const CTX_PM = 1;
export const CTX_SMSG = 2;
export const CTX_BOOT = 4;
export const CTX_BAN = 8;
export const CTX_GIB = 16;
export const CTX_POPT = 32;
export const CTX_JUMP = 64;
export const CTX_GET = 128;
export const CTX_OBSERVE = 256;
export const CTX_GHOSTJUMP = 512;

export const CONTEXT_ITEMS = [
  {
    type: 'pm',
    name: 'Admin PM',
    description: 'Send player an Admin PM.',
    flag: CTX_PM,
  },
  {
    type: 'smsg',
    name: 'Subtle Message',
    description: 'Send player a subtle message.',
    flag: CTX_SMSG,
  },
  {
    type: 'boot',
    name: 'Kick Player',
    description: 'Kick player from the server.',
    flag: CTX_BOOT,
  },
  {
    type: 'ban',
    name: 'Ban Player',
    description: 'Open ban menu for player.',
    flag: CTX_BAN,
  },
  {
    type: 'gib',
    name: 'Gib Player',
    description: 'Gib player.',
    flag: CTX_GIB,
  },
  {
    type: 'popt',
    name: 'Player Options',
    description: 'Open player options menu.',
    flag: CTX_POPT,
  },
  {
    type: 'jump',
    name: 'Jump To',
    description: 'Teleports you to an area.',
    flag: CTX_JUMP,
  },
  {
    type: 'get',
    name: 'Get Player',
    description: 'Teleport player to you.',
    flag: CTX_PM,
  },
  {
    type: 'observe',
    name: 'Observe Player',
    description: 'Observe player.',
    flag: CTX_OBSERVE,
  },
  {
    type: 'teleport',
    name: 'Teleport To',
    description: 'Teleports you to player.',
    flag: CTX_GHOSTJUMP,
  },
];
