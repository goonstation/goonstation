/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

import { useState } from 'react';
import {
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { isEscape } from 'tgui-core/keys';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { formatKeyboardEvent, isStandardKey } from './formatKeyboardEvent';
import { KeybindData, KeybindsData } from './types';

export const Keybinds = () => {
  return (
    <Window width={330} height={590}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <KeybindList />
          </Stack.Item>
          <Stack.Item>
            <Footer />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const KeybindList = () => {
  const { data } = useBackend<KeybindsData>();
  const { keys } = data;

  const [focusedKey, setFocusedKey] = useState('');

  return (
    <Section scrollable fill>
      <NoticeBox info>
        You can only rebind keys you have access to when opening the window.
        <br />
        Ex: You can only change human hotkeys if you are currently human.
      </NoticeBox>
      <LabeledList>
        <LabeledList.Item label="Action">
          Corresponding Keybind
        </LabeledList.Item>
        {keys.sort(sortKeys).map((k) => (
          <Keybind
            key={k.id}
            keybind={k}
            isFocused={k.id === focusedKey}
            setFocusedKey={setFocusedKey}
          />
        ))}
      </LabeledList>
    </Section>
  );
};

interface KeybindProps {
  keybind: KeybindData;
  isFocused: BooleanLike;
  setFocusedKey: (string) => void;
}
const Keybind = (props: KeybindProps) => {
  const { act } = useBackend<KeybindsData>();
  const { keybind, isFocused, setFocusedKey } = props;
  return (
    <LabeledList.Item label={keybind.label}>
      <Button
        onKeyDown={(event) => {
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

const Footer = () => {
  const { act } = useBackend<KeybindsData>();
  return (
    <>
      <Button onClick={() => act('confirm')} color="good" icon="save">
        Confirm
      </Button>
      <Button onClick={() => act('reset')} color="bad" icon="trash">
        Reset All Keybinding Data
      </Button>
      <Button onClick={() => act('cancel')}>Cancel</Button>
    </>
  );
};

// Default list order, before it gets shuffled around DM side, is number keys first, then string keys.
//  This function recovers that order
const sortKeys = (k1, k2) => {
  if (Number(k1.id) && Number(k2.id)) {
    return Number(k1.id) - Number(k2.id);
  } else if (Number(k1.id)) {
    return -1;
  } else if (Number(k2.id)) {
    return 1;
  } else {
    return k1.id.localeCompare(k2.id);
  }
};
