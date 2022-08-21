/**
 * @file
 * @copyright 2022
 * @author jlsnow301 (https://github.com/jlsnow301)
 * @license ISC
 */

import { Loader } from './common/Loader';
import { InputButtons, Preferences } from './common/InputButtons';
import { KEY_ENTER } from 'common/keycodes';
import { useBackend, useSharedState } from '../backend';
import { Box, Button, NumberInput, Section, Stack } from '../components';
import { Window } from '../layouts';

 type NumberInputData = {
   max_value: number | null;
   message: string;
   min_value: number | null;
   placeholder: number;
   preferences: Preferences;
   timeout: number;
   title: string;
 };

export const NumberInputModal = (_, context) => {
  const { data } = useBackend<NumberInputData>(context);
  const { message, placeholder, preferences, timeout, title } = data;
  const { large_buttons } = preferences;
  const [input, setInput] = useSharedState(context, 'input', placeholder);
  const onChange = (value: number) => {
    setInput(value);
  };
  const onClick = (value: number) => {
    setInput(value);
  };
  // NumberInput basically handles everything here
  const defaultValidState = { isValid: true, error: null };
  // Dynamically changes the window height based on the message.
  const windowHeight
     = 130 + Math.ceil(message.length / 5) + (large_buttons ? 5 : 0);

  return (
    <Window title={title} width={270} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content>
        <Section fill>
          <Stack fill vertical>
            <Stack.Item>
              <Box color="label">{message}</Box>
            </Stack.Item>
            <Stack.Item>
              <InputArea input={input} onClick={onClick} onChange={onChange} />
            </Stack.Item>
            <Stack.Item pl={!large_buttons && 4} pr={!large_buttons && 4}>
              <InputButtons input={input} inputIsValid={defaultValidState} />
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
  const { min_value, max_value, placeholder } = data;
  const { input, onClick, onChange } = props;

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
        <NumberInput
          autoFocus
          fluid
          minValue={min_value}
          maxValue={max_value}
          onChange={(_, value) => onChange(value)}
          onDrag={(_, value) => onChange(value)}
          onKeyDown={(event) => {
            const keyCode = window.event ? event.which : event.keyCode;
            if (keyCode === KEY_ENTER && input) {
              act('submit', { entry: input });
            }
          }}
          value={input || placeholder || 0}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="angle-double-right"
          onClick={() => onClick(max_value || 10000)}
          tooltip="Max"
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="redo"
          onClick={() => onClick(placeholder || 0)}
          tooltip="Reset"
        />
      </Stack.Item>
    </Stack>
  );
};
