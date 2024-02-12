/**
 * @file
 * @copyright 2022
 * @author jlsnow301 (https://github.com/jlsnow301)
 * @license ISC
 */

import { InputButtons, Validator } from './common/InputButtons';
import { useBackend, useLocalState } from '../backend';
import { Box, Section, Stack, TextArea } from '../components';
import { Window } from '../layouts';

 type TextInputData = {
   max_length: number;
   message: string;
   placeholder: string;
   title: string;
   allowEmpty: boolean;
   rows: number;
   columns: number;
 };

export const SwingSignTIM = (_, context) => {
  const { data } = useBackend<TextInputData>(context);
  const {
    max_length,
    message,
    placeholder,
    title,
    allowEmpty,
    rows,
    columns,
  } = data;
  const [input, setInput] = useLocalState(context, 'input', placeholder);
  const [inputIsValid, setInputIsValid] = useLocalState<Validator>(
    context,
    'inputIsValid',
    { isValid: allowEmpty || !!message, error: null }
  );
  const onType = (event) => {
    event.preventDefault();
    const target = event.target;
    target.value = trimText(target.value, rows, columns);
    setInputIsValid(validateInput(target.value, max_length, rows));
    setInput(target.value);
  };
  // Dynamically changes the window height based on the message.
  const windowHeight
     = 130 + Math.ceil(message.length / 5) + 75;

  return (
    <Window title={title} width={325} height={windowHeight} >
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
  const { input, inputIsValid, onType } = props;
  const textareaStyle = {
    overflow: "hidden",
    // textAlign: "center",
    whiteSpace: "pre-line",
    wrap: "hard",
    textAlignLast: "center",
  };

  return (
    <Stack.Item grow>
      <TextArea
        autoFocus
        height="100%"
        textAlign="center"
        fontFamily="Consolas"
        onInput={(event) => onType(event)}
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
  if ((!!max_length && input.length > max_length) || (!!rows && input.split(/\n/g).length>rows)) { // Added row count check
    return { isValid: false, error: `Too long!` };
  }
  return { isValid: true, error: null };
};

const trimText = (input, rows, columns) => {
  let lines = input.split(/\n/g);// Split text into rows of text


  for (let i=0; i<lines.length; i++) { // Insert newlines into overflowing lines
    if (lines[i] && lines[i].length>columns) { // Check if line overflows
      let newLine = lines[i].substring(0, columns); // Extract line from the beginning
      lines[i]=lines[i].substring(columns, lines[i].length); // Replace the old line with what remains
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
