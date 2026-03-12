/*
 * Copyright (c) 2024 @Azrun
 * SPDX-License-Identifier: MIT
 */

import { KEY_ENTER, KEY_ESCAPE } from 'common/keycodes';
import { Autofocus, Box, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { DataInputBitFieldEntry } from './common/DataInput';
import { InputButtons } from './common/InputButtons';
import { Loader } from './common/Loader';

interface BitfieldInputModalData {
  timeout;
  message;
  title;
  autofocus;
  default_value;
}

export const BitfieldInputModal = () => {
  const { act, data } = useBackend<BitfieldInputModalData>();
  const { timeout, message, title, autofocus, default_value = 0 } = data;

  return (
    <Window height={210} title={title} width={450} theme="generic">
      {!!timeout && <Loader value={timeout} />}
      <Window.Content
        onKeyDown={(event) => {
          const keyCode = window.event ? event.which : event.keyCode;
          if (keyCode === KEY_ENTER) {
            act('submit', { entry: default_value });
          }
          if (keyCode === KEY_ESCAPE) {
            act('cancel');
          }
        }}
      >
        <Stack fill vertical>
          {message && (
            <Stack.Item m={1}>
              <Section fill>
                <Box color="label" overflow="hidden">
                  {message}
                </Box>
              </Section>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Section fill>
              {!!autofocus && <Autofocus />}
              <DataInputBitFieldEntry value={default_value} />
            </Section>
          </Stack.Item>
          <Stack.Item pl={4} pr={4}>
            <InputButtons input={default_value} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
