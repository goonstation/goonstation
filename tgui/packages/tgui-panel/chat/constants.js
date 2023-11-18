/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const MAX_VISIBLE_MESSAGES = 2500;
export const MAX_PERSISTED_MESSAGES = 1000;
export const MESSAGE_SAVE_INTERVAL = 10000;
export const MESSAGE_PRUNE_INTERVAL = 60000;
export const COMBINE_MAX_MESSAGES = 5;
export const COMBINE_MAX_TIME_WINDOW = 5000;
export const IMAGE_RETRY_DELAY = 250;
export const IMAGE_RETRY_LIMIT = 10;
export const IMAGE_RETRY_MESSAGE_AGE = 60000;

// Default message type
export const MESSAGE_TYPE_UNKNOWN = 'unknown';

// Internal message type
export const MESSAGE_TYPE_INTERNAL = 'internal';

// Must match the set of defines in _std/defines/chat.dm
export const MESSAGE_TYPE_SYSTEM = 'system';
export const MESSAGE_TYPE_LOCALCHAT = 'localchat';
export const MESSAGE_TYPE_BROADCASTED = 'broadcasted';
export const MESSAGE_TYPE_RADIO = 'radio';
export const MESSAGE_TYPE_INFO = 'info';
export const MESSAGE_TYPE_WARNING = 'warning';
export const MESSAGE_TYPE_DEADCHAT = 'deadchat';
export const MESSAGE_TYPE_OOC = 'ooc';
export const MESSAGE_TYPE_LOOC = 'looc';
export const MESSAGE_TYPE_ADMINPM = 'adminpm';
export const MESSAGE_TYPE_MENTORPM = 'mentorpm';
export const MESSAGE_TYPE_COMBAT = 'combat';
export const MESSAGE_TYPE_ADMINCHAT = 'adminchat';
export const MESSAGE_TYPE_ADMINLOG = 'adminlog';
export const MESSAGE_TYPE_ATTACKLOG = 'attacklog';
export const MESSAGE_TYPE_DEBUG = 'debug';

// Metadata for each message type
export const MESSAGE_TYPES = [
  // Always-on types
  {
    type: MESSAGE_TYPE_SYSTEM,
    name: 'System Messages',
    description: 'Messages from your client, always enabled',
    selector: '.system, .motd',
    important: true,
  },
  {
    type: MESSAGE_TYPE_ADMINPM,
    name: 'Admin PMs',
    description: 'Messages to/from admins (adminhelp)',
    selector: '.bigPM, .ahelp',
    important: true,
  },
  // Basic types
  {
    type: MESSAGE_TYPE_LOCALCHAT,
    name: 'Local',
    description: 'In-character local messages (say, emote, etc)',
    selector: '.say, .emote, .sing, .robotsing, .flocknpc',
  },
  {
    type: MESSAGE_TYPE_BROADCASTED,
    name: 'Broadcasted',
    description: 'In-character messages that are sent to a group (kudzusay, roboticsay, etc) excluding deadsay',
    selector: '.roboticsay, .kudzusay, .thrallsay, .blobsay, .hivesay, .martiansay, .martianimperial, .flocksay, .ghostdronesay',
  },
  {
    type: MESSAGE_TYPE_RADIO,
    name: 'Radio',
    description: 'All departments of radio messages',
    selector: '.rstandard, .rintercom, .rcommand, .rsecurity, .rdetective, .rengineering, .rmedical, .rresearch, .rcivilian, .rsyndicate, .rintercomai, .rother, .radio',
  },
  {
    type: MESSAGE_TYPE_INFO,
    name: 'Info',
    description: 'Non-urgent messages from the game and items',
    selector: '.notice, .hint, .subtle, .internal, .success',
  },
  {
    type: MESSAGE_TYPE_WARNING,
    name: 'Warnings',
    description: 'Urgent messages from the game and items',
    selector: '.alert:not(.motd), .lawupdate, .blobalert',
  },
  {
    type: MESSAGE_TYPE_DEADCHAT,
    name: 'Deadchat',
    description: 'All of deadchat',
    selector: '.deadsay',
  },
  {
    type: MESSAGE_TYPE_OOC,
    name: 'OOC',
    description: 'Global OOC messages',
    selector: '.ooc, .adminooc, .mentorooc, .gfartooc, .newbeeooc',
  },
  {
    type: MESSAGE_TYPE_LOOC,
    name: 'LOOC',
    description: 'Local OOC messages',
    selector: '.looc, .adminlooc, .mentorlooc, .gfartlooc, .newbeelooc',
  },
  {
    type: MESSAGE_TYPE_MENTORPM,
    name: 'Mentor PMs',
    description: 'Messages to/from mentors (mentorhelp)',
    selector: '.mhelp',
  },
  {
    type: MESSAGE_TYPE_COMBAT,
    name: 'Combat',
    description: 'Urist McTraitor has stabbed you with a knife!',
    selector: '.combat',
  },
  {
    type: MESSAGE_TYPE_UNKNOWN,
    name: 'Unsorted',
    description: 'Everything we could not sort.',
  },
  // Admin stuff
  {
    type: MESSAGE_TYPE_ADMINCHAT,
    name: 'Admin Chat',
    description: 'ASAY messages',
    selector: '.adminMsgWrap',
    admin: true,
  },
  {
    type: MESSAGE_TYPE_ADMINLOG,
    name: 'Admin Log',
    description: 'ADMIN LOG: Urist McAdmin has jumped to coordinates X, Y, Z',
    selector: '.adminLog',
    admin: true,
  },
  {
    type: MESSAGE_TYPE_ATTACKLOG,
    name: 'Attack Log',
    description: 'ATTACK LOG: Urist McFisher suicided shortly after joining.',
    selector: '.attackLog',
    admin: true,
  },
  {
    type: MESSAGE_TYPE_DEBUG,
    name: 'Coder Log',
    description: 'CODER LOG: WORLD NOT FOUND!',
    selector: '.coderLog',
    admin: true,
  },
];
