/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */
import { Button, LabeledList } from 'tgui-core/components';
import { isEscape } from 'tgui-core/keys';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { formatKeyboardEvent, isStandardKey } from './formatKeyboardEvent';
import { KeybindData, KeybindsData } from './types';

interface KeybindProps {
  keybind: KeybindData;
  isFocused: BooleanLike;
  setFocusedKey: (string) => void;
}
export const Keybind = (props: KeybindProps) => {
  const { act } = useBackend<KeybindsData>();
  const { keybind, isFocused, setFocusedKey } = props;
  return (
    <LabeledList.Item label={keybind.label}>
      <Button
        onKeyDown={(event) => {
          event.preventDefault();
          if (isEscape(event.key)) {
            setFocusedKey('');
          }
          if (!isStandardKey(event)) {
            return;
          }
          setFocusedKey('');
          const value = formatKeyboardEvent(event);
          return act('changed_key', { id: keybind.id, value });
        }}
        onClick={() => {
          setFocusedKey(keybind.id);
        }}
        color={isFocused ? 'good' : null}
      >
        {isFocused ? '...' : keybind.changedValue || keybind.savedValue}
      </Button>
    </LabeledList.Item>
  );
};
