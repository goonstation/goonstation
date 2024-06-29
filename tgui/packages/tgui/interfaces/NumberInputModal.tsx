/**
 * @file
 * @copyright 2022
 * @author jlsnow301 (https://github.com/jlsnow301)
 * @license ISC
 */

import { Loader } from './common/Loader';
import { InputButtons } from './common/InputButtons';
import { KEY_ENTER, KEY_ESCAPE } from '../../common/keycodes';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, RestrictedInput, Section, Stack } from '../components';
import { Window } from '../layouts';

 type NumberInputData = {
   max_value: number | null;
   message: string;
   min_value: number | null;
   init_value: number;
   timeout: number;
   round_input: boolean;
   title: string;
   theme: string;
 };

export const NumberInputModal = (_, context) => {
  const { act, data } = useBackend<NumberInputData>(context);
  const { message, init_value, timeout, title, theme } = data;
  const [input, setInput] = useLocalState(context, 'input', init_value);

  const setValue = (value: number) => {
    if (value === input) {
      return;
    }
    setInput(value);
  };

  // Dynamically changes the window height based on the message.
  const windowHeight
     = 125 + Math.ceil(message?.length / 3);

  return (
    <Window title={title} width={270} height={windowHeight} theme={theme || 'nanotrasen'}>
      {timeout && <Loader value={timeout} />}
      <Window.Content
        onKeyDown={(event) => {
          const keyCode = window.event ? event.which : event.keyCode;
          if (keyCode === KEY_ENTER) {
            act('submit', { entry: input });
          }
          if (keyCode === KEY_ESCAPE) {
            act('cancel');
          }
        }}>
        <Section fill>
          <Stack fill vertical>
            <Stack.Item>
              <Box color="label">{message}</Box>
            </Stack.Item>
            <Stack.Item>
              <InputArea
                input={input}
                onClick={setValue}
                onChange={setValue}
                onBlur={setValue}
              />
            </Stack.Item>
            <Stack.Item pl={4} pr={4}>
              <InputButtons input={input} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

/** Gets the user input and invalidates if there's a constraint. */
const InputArea = (props, context) => {
  const { act, data } = useBackend<NumberInputData>(context);
  const { min_value, max_value, init_value, round_input } = data;
  const { input, onClick, onChange, onBlur } = props;

  return (
    <Stack fill>
      <Stack.Item>
        <Button
          icon="angle-double-left"
          onClick={() => onClick(min_value || 0)}
          tooltip="Minimum"
        />
      </Stack.Item>
      <Stack.Item grow>
        <RestrictedInput
          autoFocus
          autoSelect
          fluid
          allowFloats={!round_input}
          minValue={min_value}
          maxValue={max_value}
          onChange={(_, value) => onChange(value)}
          onBlur={(_, value) => onBlur(value)}
          onEnter={(_, value) => act('submit', { entry: value })}
          value={input}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="angle-double-right"
          onClick={() => onClick(max_value !== null ? max_value : 10000)}
          tooltip="Max"
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="redo"
          onClick={() => onClick(init_value || 0)}
          tooltip="Reset"
        />
      </Stack.Item>
    </Stack>
  );
};
