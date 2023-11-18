/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const THEMES = ['light', 'dark'];
import { sendMessage } from 'tgui/backend';

const COLOR_DARK_BG = '#28292c';
const COLOR_DARK_BG_DARKER = '#171717';
const COLOR_DARK_TEXT = '#d3d4d5';
const COLOR_DARK_COMMAND = '#28294c';

const COLOR_LIGHT_BG = '#FFFFFF';
const COLOR_LIGHT_BG_DARKER = '#f0f0f0';
const COLOR_LIGHT_TEXT = '#000000';
const COLOR_LIGHT_COMMAND = '#d3b5b5';

/**
 * Darkmode preference, originally by Kmc2000.
 *
 * This lets you switch client themes by using winset.
 *
 * If you change ANYTHING in interface/skin.dmf you need to change it here.
 *
 * There's no way round it. We're essentially changing the skin by hand.
 * It's painful but it works, and is the way Lummox suggested.
 */
export const setClientTheme = name => {
  const theme = name;
  sendMessage({
    type: 'setTheme',
    payload: { theme },
  });
  if (theme === 'light') {
    return Byond.winset({
      // Main windows
      'rpane.background-color': COLOR_LIGHT_BG,
      'rpane.text-color': COLOR_LIGHT_BG,
      'rpanewindow.background-color': COLOR_LIGHT_BG,
      'rpanewindow.text-color': COLOR_LIGHT_TEXT,
      'info.background-color': COLOR_LIGHT_BG,
      'info.text-color': COLOR_LIGHT_TEXT,
      'infowindow.background-color': COLOR_LIGHT_BG,
      'infowindow.text-color': COLOR_LIGHT_TEXT,
      'info.tab-background-color': COLOR_LIGHT_BG_DARKER,
      'info.tab-text-color': COLOR_LIGHT_TEXT,
      'mainwindow.background-color': COLOR_LIGHT_BG,
      'mainwindow.text-color': COLOR_LIGHT_TEXT,
      'mainwindow.hovertooltip.background-color': COLOR_LIGHT_BG,
      'mainwindow.hovertooltip.text-color': COLOR_LIGHT_TEXT,
      'mainvsplit.background-color': COLOR_LIGHT_BG,
      'falsepadding.background-color': COLOR_LIGHT_COMMAND,
      // Buttons
      'infob.background-color': COLOR_LIGHT_BG,
      'infob.text-color': COLOR_LIGHT_TEXT,
      'browseb.background-color': COLOR_LIGHT_BG,
      'browseb.text-color': COLOR_LIGHT_TEXT,
      'wikib.background-color': COLOR_LIGHT_BG,
      'wikib.text-color': COLOR_LIGHT_TEXT,
      'forumb.background-color': COLOR_LIGHT_BG,
      'forumb.text-color': COLOR_LIGHT_TEXT,
      'githubb.background-color': COLOR_LIGHT_BG,
      'githubb.text-color': COLOR_LIGHT_TEXT,
      'bugreportb.background-color': COLOR_LIGHT_BG,
      'bugreportb.text-color': COLOR_LIGHT_TEXT,
      'mapb.background-color': COLOR_LIGHT_BG,
      'mapb.text-color': COLOR_LIGHT_TEXT,
      'textb.background-color': COLOR_LIGHT_BG,
      'textb.text-color': COLOR_LIGHT_TEXT,
      'menub.background-color': COLOR_LIGHT_BG,
      'menub.text-color': COLOR_LIGHT_TEXT,
      // Say, OOC, me Buttons etc.
      'saybutton.background-color': COLOR_LIGHT_COMMAND,
      'saybutton.text-color': COLOR_LIGHT_TEXT,
      'input.background-color': COLOR_LIGHT_COMMAND,
      'input.text-color': COLOR_LIGHT_TEXT,
    });
  }
  if (theme === 'dark') {
    Byond.winset({
      // Main windows
      'rpane.background-color': COLOR_DARK_BG,
      'rpane.text-color': COLOR_DARK_TEXT,
      'rpanewindow.background-color': COLOR_DARK_BG,
      'rpanewindow.text-color': COLOR_DARK_TEXT,
      'info.background-color': COLOR_DARK_BG,
      'info.text-color': COLOR_DARK_TEXT,
      'infowindow.background-color': COLOR_DARK_BG,
      'infowindow.text-color': COLOR_DARK_TEXT,
      'info.tab-background-color': COLOR_DARK_BG_DARKER,
      'info.tab-text-color': COLOR_DARK_TEXT,
      'mainwindow.background-color': COLOR_DARK_BG,
      'mainwindow.text-color': COLOR_DARK_TEXT,
      'mainwindow.hovertooltip.background-color': COLOR_DARK_BG,
      'mainwindow.hovertooltip.text-color': COLOR_DARK_TEXT,
      'mainvsplit.background-color': COLOR_DARK_BG,
      'falsepadding.background-color': COLOR_DARK_COMMAND,
      // Buttons
      'infob.background-color': COLOR_DARK_BG,
      'infob.text-color': COLOR_DARK_TEXT,
      'browseb.background-color': COLOR_DARK_BG,
      'browseb.text-color': COLOR_DARK_TEXT,
      'wikib.background-color': COLOR_DARK_BG,
      'wikib.text-color': COLOR_DARK_TEXT,
      'forumb.background-color': COLOR_DARK_BG,
      'forumb.text-color': COLOR_DARK_TEXT,
      'githubb.background-color': COLOR_DARK_BG,
      'githubb.text-color': COLOR_DARK_TEXT,
      'bugreportb.background-color': COLOR_DARK_BG,
      'bugreportb.text-color': COLOR_DARK_TEXT,
      'mapb.background-color': COLOR_DARK_BG,
      'mapb.text-color': COLOR_DARK_TEXT,
      'textb.background-color': COLOR_DARK_BG,
      'textb.text-color': COLOR_DARK_TEXT,
      'menub.background-color': COLOR_DARK_BG,
      'menub.text-color': COLOR_DARK_TEXT,
      // Say, OOC, me Buttons etc.
      'saybutton.background-color': COLOR_DARK_COMMAND,
      'saybutton.text-color': COLOR_DARK_TEXT,
      'input.background-color': COLOR_DARK_COMMAND,
      'input.text-color': COLOR_DARK_TEXT,
    });
  }
};
