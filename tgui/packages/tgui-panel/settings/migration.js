/**
 * @file
 * @copyright 2023
 * @author Cheffie
 * @link https://github.com/CheffieGithub
 * @license MIT
 */

import { useDispatch } from 'common/redux';
import { updateHighlightSetting, updateSettings } from './actions';
import { chatRenderer } from '../chat/renderer';

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
  fontSize: 14,
  oddHighlight: false,
  messagePruning: true,
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
    'smessageLimitEnabled': getCookie('messageLimitEnabled'),
  };
  const dispatch = useDispatch(context);
  let message = [];
  if (oldCookies.sfontSize) {
    let fontSize = oldCookies.sfontSize;
    fontSize = fontSize.replace(/[a-z]/g, '');
    panelSettings.fontSize = fontSize;
    message.push(`Imported font size of "${fontSize}".`);
  }
  if (oldCookies.sfontType) {
    if (oldCookies.sfontType === '\'Helvetica Neue\', Helvetica, Arial') {
      panelSettings.fontFamily = 'Arial';
    } else panelSettings.fontFamily = oldCookies.sfontType;
    message.push(`Imported font family of "${panelSettings.fontFamily}".`);
  }
  if (oldCookies.stheme) {
    if (oldCookies.stheme === 'theme-default') {
      panelSettings.theme = 'light';
    } else panelSettings.theme = 'dark';
    message.push(`Imported theme of "${panelSettings.theme}".`);
  }
  if (oldCookies.soddMsgHighlight) {
    if (oldCookies.soddMsgHighlight === 'true') {
      panelSettings.oddHighlight = true;
    } else panelSettings.oddHighlight = false;
    message.push(`Imported odd highlight setting of "${panelSettings.oddHighlight}".`);
  }
  if (oldCookies.smessageLimitEnabled) {
    if (oldCookies.smessageLimitEnabled === 'true') {
      panelSettings.messagePruning = true;
    } else panelSettings.messagePruning = false;
    message.push(`Imported remove old messages setting of "${panelSettings.messagePruning}".`);
  }
  if (oldCookies.shighlightColor) {
    highlightSettings.color = oldCookies.shighlightColor;
    message.push(`Imported highlight color setting of "${highlightSettings.color}".`);
  }
  if (oldCookies.shighlightTerms) {
    let savedTerms = JSON.parse(oldCookies.shighlightTerms).filter(entry => {
      return entry !== null && /\S/.test(entry);
    });
    let actualTerms = savedTerms.length !== 0 ? savedTerms.join(', ') : null;
    if (actualTerms) {
      highlightSettings.terms = actualTerms;
      message.push(`Imported highlight terms of "${highlightSettings.terms}".`);
      message.push(`<b>Note you need to manually encase regex in forward slashes (/).</b>`);
    }
  }
  dispatch(updateSettings({
    fontSize: panelSettings.fontSize,
    fontFamily: panelSettings.fontFamily,
    theme: panelSettings.theme,
    oddHighlight: panelSettings.oddHighlight,
    messagePruning: panelSettings.messagePruning,
  }));
  if (highlightSettings.terms.length) {
    dispatch(updateHighlightSetting({
      id: 'default',
      highlightText: highlightSettings.terms,
    }));
  }
  dispatch(updateHighlightSetting({
    id: 'default',
    highlightColor: highlightSettings.color,
  }));
  if (message.length) {
    message = message.join('<br>');
    chatRenderer.sendMessage(`<span class='internal boldnshit'>${message}</span>`);
  }
  return;
};
