/**
 * @file
 * @copyright 2025
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */
import { useState } from 'react';
import { LabeledList, NoticeBox } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Keybind } from './Keybind';
import { KeybindData, KeybindsData } from './types';

export const KeybindList = () => {
  const { data } = useBackend<KeybindsData>();
  const { keys } = data;

  const [focusedKey, setFocusedKey] = useState('');

  return (
    <>
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
    </>
  );
};

// Default list order, before it gets shuffled around DM side, is number keys first, then string keys.
//  This function recovers that order
const sortKeys = (k1: KeybindData, k2: KeybindData) => {
  if (Number(k1.id) && Number(k2.id)) {
    return Number(k1.id) - Number(k2.id);
  } else if (Number(k1.id)) {
    return -1;
  } else if (Number(k2.id)) {
    return 1;
  }
  return k1.id.localeCompare(k2.id);
};
