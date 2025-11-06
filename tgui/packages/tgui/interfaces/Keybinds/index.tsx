/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */
import { Section, Stack } from 'tgui-core/components';

import { Window } from '../../layouts';
import { Footer } from './Footer';
import { KeybindList } from './KeybindList';

export const Keybinds = () => {
  return (
    <Window width={330} height={590} title="Keybinding Customization">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Section scrollable fill>
              <KeybindList />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Footer />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
