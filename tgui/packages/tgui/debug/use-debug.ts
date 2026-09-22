/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { KEY_BACKSPACE, KEY_F11, KEY_F12 } from 'common/keycodes';

import { debugLayoutAtom, kitchenSinkAtom, store } from '../events/store';
// |GOONSTATION-CHANGE| Use Goon's event and hotkey layer.
import { globalEvents, type KeyEvent } from '../global-events';
import { acquireHotKey } from '../hotkeys';

export function setDebugHotKeys(): void {
  acquireHotKey(KEY_F11);
  acquireHotKey(KEY_F12);

  globalEvents.on('keydown', (key: KeyEvent) => {
    if (key.code === KEY_F11) {
      store.set(debugLayoutAtom, (prev) => !prev);
    }

    if (key.code === KEY_F12) {
      store.set(kitchenSinkAtom, (prev) => !prev);
    }

    if (key.ctrl && key.alt && key.code === KEY_BACKSPACE) {
      // NOTE: We need to call this in a timeout, because we need a clean
      // stack in order for this to be a fatal error.
      setTimeout(() => {
        throw new Error(
          'OOPSIE WOOPSIE!! UwU We made a fucky wucky!! A wittle' +
            ' fucko boingo! The code monkeys at our headquarters are' +
            ' working VEWY HAWD to fix this!',
        );
      });
    }
  });
}
