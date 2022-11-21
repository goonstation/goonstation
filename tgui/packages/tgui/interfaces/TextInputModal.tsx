/**
 * @file
 * @copyright 2022
 * @author jlsnow301 (https://github.com/jlsnow301)
 * @license ISC
 */

import { Loader } from './common/Loader';
import { InputButtons, Validator } from './common/InputButtons';
import { useBackend, useSharedState } from '../backend';
import { KEY_ENTER } from 'common/keycodes';
import { Box, Input, Section, Stack, TextArea } from '../components';
import { Window } from '../layouts';

 type TextInputData = {
   max_length: number;
   message: string;
   multiline: boolean;
   placeholder: string;
   timeout: number;
   title: string;
   allowEmpty: boolean;
 };

export const TextInputModal = (_, context) => {
  const { data } = useBackend<TextInputData>(context);
  const {
    max_length,
    message,
    multiline,
    placeholder,
    timeout,
    title,
    allowEmpty,
  } = data;
  const [input, setInput] = useSharedState(context, 'input', placeholder);
  const [inputIsValid, setInputIsValid] = useSharedState<Validator>(
    context,
    'inputIsValid',
    { isValid: allowEmpty || !!message, error: null }
  );
  const onType = (event) => {
    event.preventDefault();
    const target = event.target;
    setInputIsValid(validateInput(target.value, max_length, allowEmpty));
    setInput(target.value);
  };
  // Dynamically changes the window height based on the message.
  const windowHeight
     = 130 + Math.ceil(message.length / 5) + (multiline ? 75 : 0);

  return (
    <Window title={title} width={325} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content>
        <Section fill>
          <Stack fill vertical>
            <Stack.Item>
              <Box color="label">{message}</Box>
            </Stack.Item>
            <InputArea
              input={input}
              inputIsValid={inputIsValid}
              onType={onType}
            />
            <Stack.Item pl={5} pr={5}>
              <InputButtons input={input} inputIsValid={inputIsValid} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

/** Gets the user input and invalidates if there's a constraint. */
const InputArea = (props, context) => {
  const { act, data } = useBackend<TextInputData>(context);
  const { multiline } = data;
  const { input, inputIsValid, onType } = props;

  if (!multiline) {
    return (
      <Stack.Item>
        <Input
          autoFocus
          fluid
          onInput={(event) => onType(event)}
          onKeyDown={(event) => {
            const keyCode = window.event ? event.which : event.keyCode;
            if (keyCode === KEY_ENTER && inputIsValid) {
              act('submit', { entry: input });
            }
          }}
          placeholder="Type something..."
          value={input}
        />
      </Stack.Item>
    );
  } else {
    return (
      <Stack.Item grow>
        <TextArea
          autoFocus
          height="100%"
          onInput={(event) => onType(event)}
          onKeyDown={(event) => {
            const keyCode = window.event ? event.which : event.keyCode;
            if (keyCode === KEY_ENTER && inputIsValid) {

              act('submit', { entry: input });
            }
          }}
          placeholder="Type something..."
          value={input}
        />
      </Stack.Item>
    );
  }
};

/** Helper functions */
const validateInput = (input, max_length, allowEmpty) => {
  if (!!max_length && input.length > max_length) {
    return { isValid: false, error: `Too long!` };
  } else if (input.length === 0 && !allowEmpty) {
    return { isValid: false, error: null };
  }
  return { isValid: true, error: null };
};
