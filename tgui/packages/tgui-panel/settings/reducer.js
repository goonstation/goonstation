/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { addHighlightSetting, changeSettingsTab, loadSettings, openChatSettings, removeHighlightSetting, toggleSettings, updateHighlightSetting, updateSettings } from './actions';
import { FONTS, MAX_HIGHLIGHT_SETTINGS, SETTINGS_TABS } from './constants';
import { createDefaultHighlightSetting } from './model';
import { setClientTheme } from '../themes';

const defaultHighlightSetting = createDefaultHighlightSetting();

const initialState = {
  version: 1,
  fontFamily: FONTS[0],
  fontSize: 14,
  lineHeight: 1.4,
  oddHighlight: false,
  messagePruning: true,
  theme: 'dark',
  adminMusicVolume: 0.5,
  highlightSettings: [defaultHighlightSetting.id],
  highlightSettingById: {
    [defaultHighlightSetting.id]: defaultHighlightSetting,
  },
  view: {
    visible: false,
    activeTab: SETTINGS_TABS[0].id,
  },
};

export const settingsReducer = (state = initialState, action) => {
  const { type, payload } = action;
  if (type === updateSettings.type) {
    return {
      ...state,
      ...payload,
    };
  }
  if (type === loadSettings.type) {
    // Validate version and/or migrate state
    if (!payload?.version) {
      // Dumb hack for first load which has no payload but we still want to set the theme from default settings
      setClientTheme(state.theme);
      return state;
    }
    delete payload.view;
    const nextState = {
      ...state,
      ...payload,
    };
    // Lazy init the list for compatibility reasons
    if (!nextState.highlightSettings) {
      nextState.highlightSettings = [defaultHighlightSetting.id];
      nextState.highlightSettingById[defaultHighlightSetting.id]
        = defaultHighlightSetting;
    }
    // Compensating for mishandling of default highlight settings
    else if (!nextState.highlightSettingById[defaultHighlightSetting.id]) {
      nextState.highlightSettings = [
        defaultHighlightSetting.id,
        ...nextState.highlightSettings,
      ];
      nextState.highlightSettingById[defaultHighlightSetting.id]
        = defaultHighlightSetting;
    }
    // Update the highlight settings for default highlight
    // settings compatibility
    const highlightSetting
      = nextState.highlightSettingById[defaultHighlightSetting.id];
    highlightSetting.highlightColor = nextState.highlightColor;
    highlightSetting.highlightText = nextState.highlightText;
    return nextState;
  }
  if (type === toggleSettings.type) {
    return {
      ...state,
      view: {
        ...state.view,
        visible: !state.view.visible,
      },
    };
  }
  if (type === openChatSettings.type) {
    return {
      ...state,
      view: {
        ...state.view,
        visible: true,
        activeTab: 'chatPage',
      },
    };
  }
  if (type === changeSettingsTab.type) {
    const { tabId } = payload;
    return {
      ...state,
      view: {
        ...state.view,
        activeTab: tabId,
      },
    };
  }
  if (type === addHighlightSetting.type) {
    const highlightSetting = payload;
    if (state.highlightSettings.length >= MAX_HIGHLIGHT_SETTINGS) {
      return state;
    }
    return {
      ...state,
      highlightSettings: [...state.highlightSettings, highlightSetting.id],
      highlightSettingById: {
        ...state.highlightSettingById,
        [highlightSetting.id]: highlightSetting,
      },
    };
  }
  if (type === removeHighlightSetting.type) {
    const { id } = payload;
    const nextState = {
      ...state,
      highlightSettings: [...state.highlightSettings],
      highlightSettingById: {
        ...state.highlightSettingById,
      },
    };
    if (id === defaultHighlightSetting.id) {
      nextState.highlightSettings[defaultHighlightSetting.id]
        = defaultHighlightSetting;
    } else {
      delete nextState.highlightSettingById[id];
      nextState.highlightSettings = nextState.highlightSettings.filter(
        (sid) => sid !== id
      );
      if (!nextState.highlightSettings.length) {
        nextState.highlightSettings.push(defaultHighlightSetting.id);
        nextState.highlightSettingById[defaultHighlightSetting.id]
          = defaultHighlightSetting;
      }
    }
    return nextState;
  }
  if (type === updateHighlightSetting.type) {
    const { id, ...settings } = payload;
    const nextState = {
      ...state,
      highlightSettings: [...state.highlightSettings],
      highlightSettingById: {
        ...state.highlightSettingById,
      },
    };

    // We need a color to properly do highlights
    // If color is not formatted with a # put it in
    // (Internally has the updated value in the text box but it doesn't update until reload as its being edited)
    // If color is blank check the previous color
    // If thats blank too reset to default
    const color = settings.highlightColor;

    if (color) {
      if (!color.startsWith('#')) {
        settings.highlightColor = `#${color}`;
      }
    } else if (!nextState.highlightColor) {
      settings.highlightColor = '#ffdd44';
    }

    // Transfer this data from the default highlight setting
    // so they carry over to other servers
    if (id === defaultHighlightSetting.id) {
      if (settings.highlightText) {
        nextState.highlightText = settings.highlightText;
      }
      if (settings.highlightColor) {
        nextState.highlightColor = settings.highlightColor;
      }
    }

    if (nextState.highlightSettingById[id]) {
      nextState.highlightSettingById[id] = {
        ...nextState.highlightSettingById[id],
        ...settings,
      };
    }

    return nextState;
  }
  return state;
};
