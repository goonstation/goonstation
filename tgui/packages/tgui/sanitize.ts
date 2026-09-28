/**
 * Copyright (c) 2020 Warlockd
 * SPDX-License-Identifier: MIT
 */

import DOMPurify from 'dompurify';

import { configAtom, store } from './events/store';

// Default values
export let sanitizeDefAllowTags = [
  'b',
  'blockquote',
  'br',
  'center',
  'code',
  'dd',
  'del',
  'div',
  'dl',
  'dt',
  'em',
  'font',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'hr',
  'i',
  'ins',
  'li',
  'menu',
  'ol',
  'p',
  'pre',
  'span',
  'strong',
  'table',
  'tbody',
  'td',
  'th',
  'thead',
  'tfoot',
  'tr',
  'u',
  'ul',
];

// Background is here because it accepts image urls
export let sanitizeDefForbidAttrs = ['class', 'style', 'background'];

// Advanced HTML tags that we can trust admins (but not players) with
const advTag = ['img'];

// Inline styles may only load our own paper assets via resource() (CDN url, or a bare filename locally)
DOMPurify.addHook('uponSanitizeAttribute', (_node, data) => {
  if (data.attrName !== 'style' || !data.attrValue.includes('(')) {
    return;
  }
  const { style } = document.createElement('div');
  style.cssText = data.attrValue;
  const cdn = store.get(configAtom)?.cdn;
  // Delete each allowed url() from a copy of the style.
  // Urls still left in `rest` aren't allowed, the check below drops the attrib.
  const rest = style.cssText.replace(/url\("([^"\\]*)"\)/g, (m, url) =>
    // Local: a bare filename like `bob.png`.
    // no slashes or colons, nor can start with `.`
    /^[\w-][\w.-]*$/.test(url) ||
    // CDN: only the paper folder, no path traversal
    (cdn &&
      url.startsWith(`${cdn}/images/tgui/paper/`) &&
      !/\.\.|%2e/i.test(url))
      ? ''
      : m,
  );
  // Leftover urls, image fns, or escapes
  data.keepAttr = !/\\|(?:url|image(?:-set)?|var|env|attr)\(/i.test(rest);
  data.attrValue = style.cssText;
});

/**
 * Feed it a string and it should spit out a sanitized version.
 *
 * @param input - Input HTML string to sanitize
 * @param advHtml - Flag to enable/disable advanced HTML
 * @param tags - List of allowed HTML tags
 * @param forbidAttr - List of forbidden HTML attributes
 * @param advTags - List of advanced HTML tags allowed for trusted sources

 */
export const sanitizeText = (
  input: string,
  advHtml = false,
  tags = sanitizeDefAllowTags,
  forbidAttr = sanitizeDefForbidAttrs,
  advTags = advTag,
) => {
  // This is VERY important to think first if you NEED
  // the tag you put in here.  We are pushing all this
  // though dangerouslySetInnerHTML and even though
  // the default DOMPurify kills javascript, it doesn't
  // kill href links or such
  if (advHtml) {
    tags = tags.concat(advTags);
  }
  return DOMPurify.sanitize(input, {
    ALLOWED_TAGS: tags,
    FORBID_ATTR: forbidAttr,
    FORCE_BODY: true,
  });
};
