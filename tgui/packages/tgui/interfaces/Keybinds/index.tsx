/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

import {
  Box,
  Button,
  Input,
  LabeledList,
  NoticeBox,
  Section,
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
        <Section scrollable>
          <Box maxHeight="500px">
            <NoticeBox info>
              You can only rebind keys you have access to when opening the
              window.
              <br />
              Ex: You can only change human hotkeys if you are currently human.
            </NoticeBox>
            <LabeledList>
              <LabeledList.Item label="Action">
                Corresponding Keybind
              </LabeledList.Item>
              {keys.map((k) => (
                <LabeledList.Item key={k.key} label={k.action}>
                  <Input
                    value={k.unparse}
                    onChange={(_e, value) =>
                      act('changed_key', { action: k.key + '', key: value })
                    }
                  />
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Box>
        </Section>

        <Button onClick={() => act('confirm')} color="good" icon="save">
          Confirm
        </Button>
        <Button onClick={() => act('reset')} color="bad" icon="trash">
          Reset All Keybinding Data
        </Button>
        <Button onClick={() => act('cancel')}>Cancel</Button>
      </Window.Content>
    </Window>
  );
};
