/**
 * @file
 * @copyright 2025
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */
import { useRef } from 'react';
import { Button, LabeledList } from 'tgui-core/components';
import { isEscape } from 'tgui-core/keys';

import { useBackend } from '../../backend';
import { formatKeyboardEvent, isStandardKey } from './formatKeyboardEvent';
import { KeybindData, KeybindsData } from './types';

interface KeybindProps {
  keybind: KeybindData;
  isFocused: boolean;
  setFocusedKey: (string) => void;
}
export const Keybind = (props: KeybindProps) => {
  const { act } = useBackend<KeybindsData>();
  const { keybind, isFocused, setFocusedKey } = props;

  const lastEvent = useRef<React.KeyboardEvent<HTMLElement> | null>(null);

  return (
    <LabeledList.Item label={keybind.label}>
      <Button
        onKeyDown={(event) => {
          event.preventDefault();
          if (!isFocused) {
            return;
          }
          if (isEscape(event.key)) {
            setFocusedKey('');
            return;
          }
          if (!isStandardKey(event)) {
            // Store the event in case the key is released in which case we'll want to bind to this non-Standard key.
            lastEvent.current = event;
            return;
          }
          setFocusedKey('');
          const value = formatKeyboardEvent(event);
          lastEvent.current = null;
          act('changed_key', { id: keybind.id, value });
        }}
        onKeyUp={(event) => {
          event.preventDefault();
          if (!isFocused) {
            return;
          }
          if (!lastEvent.current) {
            return;
          }
          // If we release a key and we're still in keybind editing mode, it's time to bind whatever we had.
          setFocusedKey('');
          const value = formatKeyboardEvent(lastEvent.current);
          lastEvent.current = null;
          act('changed_key', { id: keybind.id, value });
        }}
        onClick={() => {
          setFocusedKey(keybind.id);
        }}
        color={isFocused ? 'good' : undefined}
      >
        {isFocused ? '...' : (keybind.changedValue ?? keybind.savedValue)}
      </Button>
    </LabeledList.Item>
  );
};
