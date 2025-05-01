/**
 * @file
 * @copyright 2023
 * @author Ozzzim (https://github.com/Ozzzim)
 * @license ISC
 */

import { useState } from 'react';
import { Box, Section, Stack, TextArea } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InputButtons } from './common/InputButtons';

type TextInputData = {
  max_length: number;
  message: string;
  placeholder: string;
  title: string;
  allowEmpty: boolean;
  rows: number;
  columns: number;
};

interface Validator {
  isValid: boolean;
  error: string | null;
}

export const SwingSignTIM = () => {
  const { data } = useBackend<TextInputData>();
  const { max_length, message, placeholder, title, allowEmpty, rows, columns } =
    data;
  const [input, setInput] = useState(placeholder);
  const [inputIsValid, setInputIsValid] = useState<Validator>({
    isValid: allowEmpty || !!message,
    error: null,
  });
  const onType = (event) => {
    event.preventDefault();
    const target = event.target;
    target.value = trimText(target.value, rows, columns);
    setInputIsValid(validateInput(target.value, max_length, rows));
    setInput(target.value);
  };
  // Dynamically changes the window height based on the message.
  const windowHeight = 130 + Math.ceil(message.length / 5) + 75;

  return (
    <Window title={title} width={325} height={windowHeight}>
      <Window.Content>
        <Section fill>
          <Stack fill vertical>
            <Stack.Item>
              <Box color="label">{message}</Box>
            </Stack.Item>
            <InputArea input={input} onType={onType} />
            {!inputIsValid.isValid && (
              <Stack.Item>{inputIsValid.error}</Stack.Item>
            )}
            <Stack.Item pl={5} pr={5}>
              <InputButtons input={input} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

interface InputAreaProps {
  input: string;
  onType: (v: string) => void;
}

/** Gets the user input and invalidates if there's a constraint. */
const InputArea = (props: InputAreaProps) => {
  const { act } = useBackend<TextInputData>();
  const { input, onType } = props;
  const textareaStyle = {
    overflow: 'hidden',
    whiteSpace: 'pre-line',
    wrap: 'hard',
    textAlignLast: 'center' as const,
  };

  return (
    <Stack.Item grow>
      <TextArea
        autoFocus
        height="100%"
        textAlign="center"
        fontFamily="Consolas"
        onChange={onType}
        onEnter={() => {
          act('submit', { entry: input });
        }}
        placeholder="Type something..."
        style={textareaStyle}
        value={input}
      />
    </Stack.Item>
  );
};

/** Helper functions */
const validateInput = (input, max_length, rows) => {
  if (
    (!!max_length && input.length > max_length) ||
    (!!rows && input.split(/\n/g).length > rows)
  ) {
    // Added row count check
    return { isValid: false, error: `Too long!` };
  }
  return { isValid: true, error: null };
};

const trimText = (input, rows, columns) => {
  let lines = input.split(/\n/g); // Split text into rows of text

  for (let i = 0; i < lines.length; i++) {
    // Insert newlines into overflowing lines
    if (lines[i] && lines[i].length > columns) {
      // Check if line overflows
      let newLine = lines[i].substring(0, columns); // Extract line from the beginning
      lines[i] = lines[i].substring(columns, lines[i].length); // Replace the old line with what remains
      lines.splice(i, 0, newLine); // Insert new line into the [i] spot
    }
  }

  // Putting row check in validateInput is a more elegant solution since it won't delete overflowing newlines.
  // Keeping below just in case
  // if (lines && lines.length>rows) { // Delete excess rows
  //  lines.splice(rows, lines.length-rows);
  // }
  return lines.join('\n');
};
