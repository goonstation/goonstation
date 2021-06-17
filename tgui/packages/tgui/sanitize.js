/**
 * Copyright (c) 2020 Warlockd
 * SPDX-License-Identifier: MIT
 */

import DOMPurify from 'dompurify';

// Default values
let defAllowedTags = [
  'b',
  'br',
  'center',
  'code',
  'div',
  'font',
  'hr',
  'i',
  'li',
  'menu',
  'ol',
  'p',
  'pre',
  'span',
  'table',
  'td',
  'th',
  'tr',
  'u',
  'ul',
];
let defForbidAttr = ['class', 'style'];

/**
 * Feed it a string and it should spit out a sanitized version.
 *
 * @param {string} input
 * @param {array} tags
 * @param {array} forbidAttr
 */
export const sanitizeText = (input, tags = defAllowedTags,
  forbidAttr = defForbidAttr) => {
  // This is VERY important to think first if you NEED
  // the tag you put in here.  We are pushing all this
  // though dangerouslySetInnerHTML and even though
  // the default DOMPurify kills javascript, it dosn't
  // kill href links or such
  return DOMPurify.sanitize(input, {
    ALLOWED_TAGS: tags,
    FORBID_ATTR: forbidAttr,
  });
};
