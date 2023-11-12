/**
 * @file
 * @copyright 2023
 * @author Cheffie
 * @link https://github.com/CheffieGithub
 * @license MIT
 */

import { useDispatch } from 'common/redux';
import { updateHighlightSetting, updateSettings } from './actions';

const decoder = decodeURIComponent || unescape;

const getCookie = (cname) => {
  let name = cname + '=';
  let ca = document.cookie.split(';');
  for (let i = 0; i < ca.length; i++) {
    let c = ca[i];
    while (c.charAt(0) === ' ') c = c.substring(1);
    if (c.indexOf(name) === 0) {
      return decoder(c.substring(name.length, c.length));
    }
  }
  return '';
};

const panelSettings = {
  fontFamily: 'Arial',
  fontSize: 13,
  oddHighlight: false,
  theme: 'dark',
};
const highlightSettings = {
  terms: '',
  color: '#FFFF00',
};

export const doMigration = (context) => {
  const oldCookies = {
    'sfontSize': getCookie('fontsize'),
    'sfontType': getCookie('fonttype'),
    'shighlightTerms': getCookie('highlightterms'),
    'shighlightColor': getCookie('highlightcolor'),
    'stheme': getCookie('theme'),
    'soddMsgHighlight': getCookie('oddMsgHighlight'),
  };
  const dispatch = useDispatch(context);
  if (oldCookies.sfontSize) {
    let fontSize = oldCookies.sfontSize;
    fontSize = fontSize.replace(/[a-z]/g, '');
    panelSettings.fontSize = fontSize;
  }
  if (oldCookies.stheme) {
    if (oldCookies.stheme === 'theme-default') {
      panelSettings.theme = 'light';
    } else panelSettings.theme = 'dark';
  }
  if (oldCookies.sfontType) {
    panelSettings.fontFamily = oldCookies.sfontType;
  }
  if (oldCookies.soddMsgHighlight) {
    if (oldCookies.soddMsgHighlight === 'true') {
      panelSettings.oddHighlight = true;
    } else panelSettings.oddHighlight = false;
  }
  if (oldCookies.shighlightColor) {
    highlightSettings.color = oldCookies.shighlightColor;
  }
  if (oldCookies.shighlightTerms) {
    let savedTerms = JSON.parse(oldCookies.shighlightTerms).filter(entry => {
      return entry !== null && /\S/.test(entry);
    });
    let actualTerms = savedTerms.length !== 0 ? savedTerms.join(', ') : null;
    if (actualTerms) {
      highlightSettings.terms = actualTerms;
    }
  }
  dispatch(updateSettings({
    fontSize: panelSettings.fontSize,
    fontFamily: panelSettings.fontFamily,
    theme: panelSettings.theme,
    oddHighlight: panelSettings.oddHighlight,
  }));
  if (highlightSettings.terms.length) {
    dispatch(updateHighlightSetting({
      id: 'default',
      highlightText: highlightSettings.terms,
      highlightColor: highlightSettings.color,
    }));
  }
  return;
};
