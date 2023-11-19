/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createUuid } from 'common/uuid';
import { MESSAGE_TYPE_INTERNAL, MESSAGE_TYPES } from './constants';

export const canPageAcceptType = (page, type) => (
  type.startsWith(MESSAGE_TYPE_INTERNAL) || page.acceptedTypes[type]
);

export const createPage = obj => {
  const acceptedTypes = {};
  for (let typeDef of MESSAGE_TYPES) {
    acceptedTypes[typeDef.type] = true;
  }
  return {
    id: createUuid(),
    name: 'New Tab',
    acceptedTypes,
    unreadCount: 0,
    createdAt: Date.now(),
    ...obj,
  };
};

export const createMainPage = () => {
  const acceptedTypes = {};
  for (let typeDef of MESSAGE_TYPES) {
    acceptedTypes[typeDef.type] = true;
  }
  return createPage({
    name: 'Main',
    acceptedTypes,
  });
};

export const createMessage = payload => ({
  createdAt: Date.now(),
  ...payload,
});

export const serializeMessage = message => ({
  type: message.type,
  text: message.text,
  html: message.html,
  group: message.group, /* GOON ADD: support for output grouping for spam reduction */
  forceScroll: message.forceScroll, /* GOON ADD: support for force scrolling messages*/
  times: message.times,
  createdAt: message.createdAt,
});

export const isSameMessage = (a, b) => (
  typeof a.text === 'string' && a.text === b.text
  || typeof a.html === 'string' && a.html === b.html
);

/* GOON ADD: support for output grouping for spam reduction */
export const isSameGroup = (a, b) => (
  typeof a.group === 'string' && a.group === b.group
);
