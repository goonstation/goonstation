/**
 * @file
 * @copyright 2025
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */
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
  return (
    <LabeledList.Item label={keybind.label}>
      <Button
        onKeyDown={(event) => {
          event.preventDefault();
          if (isEscape(event.key)) {
            setFocusedKey('');
            return;
          }
          if (!isStandardKey(event)) {
            return;
          }
          setFocusedKey('');
          const value = formatKeyboardEvent(event);
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
