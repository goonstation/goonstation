/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

import {
  Button,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { KeybindsData } from './types';

export const Keybinds = () => {
  const { data, act } = useBackend<KeybindsData>();
  const { keys } = data;
  return (
    <Window width={330} height={590}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Section scrollable fill>
              <NoticeBox info>
                You can only rebind keys you have access to when opening the
                window.
                <br />
                Ex: You can only change human hotkeys if you are currently
                human.
              </NoticeBox>
              <LabeledList>
                <LabeledList.Item label="Action">
                  Corresponding Keybind
                </LabeledList.Item>
                {keys.sort(sortKeys).map((k) => (
                  <LabeledList.Item key={k.id} label={k.label}>
                    <Input
                      value={k.changedValue || k.savedValue}
                      onChange={(_e, value) =>
                        act('changed_key', { id: k.id, value })
                      }
                    />
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Button onClick={() => act('confirm')} color="good" icon="save">
              Confirm
            </Button>
            <Button onClick={() => act('reset')} color="bad" icon="trash">
              Reset All Keybinding Data
            </Button>
            <Button onClick={() => act('cancel')}>Cancel</Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
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
