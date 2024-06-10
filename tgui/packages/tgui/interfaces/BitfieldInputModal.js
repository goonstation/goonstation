/*
* Copyright (c) 2024 @Azrun
* SPDX-License-Identifier: MIT
*/

import { Loader } from './common/Loader';
import { useBackend } from '../backend';
import { InputButtons } from './common/InputButtons';
import { Autofocus, Box, Section, Stack } from '../components';
import { Window } from '../layouts';
import { DataInputBitFieldEntry } from './common/DataInput';
import { KEY_ENTER, KEY_ESCAPE } from '../../common/keycodes';


export const BitfieldInputModal = (_, context) => {
  const { act, data } = useBackend(context);
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
        }}>
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
