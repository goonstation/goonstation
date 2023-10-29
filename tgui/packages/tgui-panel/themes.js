/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const THEMES = ['light', 'dark'];

const COLOR_DARK_BG = '#202020';
const COLOR_DARK_BG_DARKER = '#171717';
const COLOR_DARK_TEXT = '#dfdfcf';

const COLOR_LIGHT_BG = '#FFFFFF';
const COLOR_LIGHT_TEXT = '#000000';

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
  if (name === 'light') {
    return Byond.winset({
      // Main windows
      'infowindow.background-color': COLOR_LIGHT_BG,
      'infowindow.text-color': COLOR_LIGHT_TEXT,
      'info.background-color': COLOR_LIGHT_BG,
      'info.text-color': COLOR_LIGHT_TEXT,
      'browseroutput.background-color': COLOR_LIGHT_BG,
      'browseroutput.text-color': COLOR_LIGHT_TEXT,
      'outputwindow.background-color': COLOR_LIGHT_BG,
      'outputwindow.text-color': COLOR_LIGHT_TEXT,
      'mainwindow.background-color': COLOR_LIGHT_BG,
      'split.background-color': COLOR_LIGHT_BG,
      // Buttons
      'changelog.background-color': COLOR_LIGHT_BG,
      'changelog.text-color': COLOR_LIGHT_TEXT,
      'rules.background-color': COLOR_LIGHT_BG,
      'rules.text-color': COLOR_LIGHT_TEXT,
      'wiki.background-color': COLOR_LIGHT_BG,
      'wiki.text-color': COLOR_LIGHT_TEXT,
      'forum.background-color': COLOR_LIGHT_BG,
      'forum.text-color': COLOR_LIGHT_TEXT,
      'github.background-color': COLOR_LIGHT_BG,
      'github.text-color': COLOR_LIGHT_TEXT,
      'report-issue.background-color': COLOR_LIGHT_BG,
      'report-issue.text-color': COLOR_LIGHT_TEXT,
      // Status and verb tabs
      'output.background-color': COLOR_LIGHT_BG,
      'output.text-color': COLOR_LIGHT_TEXT,
      'statwindow.background-color': COLOR_LIGHT_BG,
      'statwindow.text-color': COLOR_LIGHT_TEXT,
      'stat.background-color': '#FFFFFF',
      'stat.tab-background-color': COLOR_LIGHT_BG,
      'stat.text-color': COLOR_LIGHT_TEXT,
      'stat.tab-text-color': COLOR_LIGHT_TEXT,
      'stat.prefix-color': COLOR_LIGHT_TEXT,
      'stat.suffix-color': COLOR_LIGHT_TEXT,
      // Say, OOC, me Buttons etc.
      'saybutton.background-color': COLOR_LIGHT_BG,
      'saybutton.text-color': COLOR_LIGHT_TEXT,
      'oocbutton.background-color': COLOR_LIGHT_BG,
      'oocbutton.text-color': COLOR_LIGHT_TEXT,
      'mebutton.background-color': COLOR_LIGHT_BG,
      'mebutton.text-color': COLOR_LIGHT_TEXT,
      'asset_cache_browser.background-color': COLOR_LIGHT_BG,
      'asset_cache_browser.text-color': COLOR_LIGHT_TEXT,
      'tooltip.background-color': COLOR_LIGHT_BG,
      'tooltip.text-color': COLOR_LIGHT_TEXT,
    });
  }
  if (name === 'dark') {
    Byond.winset({
      // Main windows
      'infowindow.background-color': COLOR_DARK_BG,
      'infowindow.text-color': COLOR_DARK_TEXT,
      'info.background-color': COLOR_DARK_BG,
      'info.text-color': COLOR_DARK_TEXT,
      'browseroutput.background-color': COLOR_DARK_BG,
      'browseroutput.text-color': COLOR_DARK_TEXT,
      'outputwindow.background-color': COLOR_DARK_BG,
      'outputwindow.text-color': COLOR_DARK_TEXT,
      'mainwindow.background-color': COLOR_DARK_BG,
      'split.background-color': COLOR_DARK_BG,
      // Buttons
      'changelog.background-color': '#494949',
      'changelog.text-color': COLOR_DARK_TEXT,
      'rules.background-color': '#494949',
      'rules.text-color': COLOR_DARK_TEXT,
      'wiki.background-color': '#494949',
      'wiki.text-color': COLOR_DARK_TEXT,
      'forum.background-color': '#494949',
      'forum.text-color': COLOR_DARK_TEXT,
      'github.background-color': '#3a3a3a',
      'github.text-color': COLOR_DARK_TEXT,
      'report-issue.background-color': '#492020',
      'report-issue.text-color': COLOR_DARK_TEXT,
      // Status and verb tabs
      'output.background-color': COLOR_DARK_BG_DARKER,
      'output.text-color': COLOR_DARK_TEXT,
      'statwindow.background-color': COLOR_DARK_BG_DARKER,
      'statwindow.text-color': COLOR_DARK_TEXT,
      'stat.background-color': COLOR_DARK_BG_DARKER,
      'stat.tab-background-color': COLOR_DARK_BG,
      'stat.text-color': COLOR_DARK_TEXT,
      'stat.tab-text-color': COLOR_DARK_TEXT,
      'stat.prefix-color': COLOR_DARK_TEXT,
      'stat.suffix-color': COLOR_DARK_TEXT,
      // Say, OOC, me Buttons etc.
      'saybutton.background-color': COLOR_DARK_BG,
      'saybutton.text-color': COLOR_DARK_TEXT,
      'oocbutton.background-color': COLOR_DARK_BG,
      'oocbutton.text-color': COLOR_DARK_TEXT,
      'mebutton.background-color': COLOR_DARK_BG,
      'mebutton.text-color': COLOR_DARK_TEXT,
      'asset_cache_browser.background-color': COLOR_DARK_BG,
      'asset_cache_browser.text-color': COLOR_DARK_TEXT,
      'tooltip.background-color': COLOR_DARK_BG,
      'tooltip.text-color': COLOR_DARK_TEXT,
    });
  }
};
