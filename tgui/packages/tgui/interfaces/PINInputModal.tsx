/**
 * @file
 * @copyright 2024
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license MIT
 */

import { Loader } from './common/Loader';
import { KEY_0, KEY_9, KEY_BACKSPACE, KEY_ENTER, KEY_ESCAPE, KEY_NUMPAD_0, KEY_NUMPAD_9, KEY_NUMPAD_DECIMAL } from '../../common/keycodes';
import { useBackend, useLocalState } from '../backend';
import { Button, NoticeBox, NumberInput, Section, Stack } from '../components';
import { Window } from '../layouts';

type PINInputData = {
  message: string;
  max_value: number | null;
  min_value: number | null;
  init_value: number;
  timeout: number;
  title: string;
  theme: string;
};

export const PINInputModal = (_, context) => {
  const { act, data } = useBackend<PINInputData>(context);
  const { message, init_value, timeout, title, theme } = data;
  const [input, setInput] = useLocalState(context, 'input', init_value);
  const onChange = (value: number) => {
    setInput(value);
  };
  const onClick = (value: number) => {
    if ((input || 0).toString().length < 4) {
      setInput(input * 10 + value);
    } else {
      // Change the last digit of the input.
      setInput(Math.floor(input / 10) * 10 + value);
    }
  };

  return (
    <Window title={title} width={160} height={275} theme={theme || 'nanotrasen'}>
      {timeout && <Loader value={timeout} />}
      <Window.Content
        onKeyDown={(event) => {
          const keyCode = window.event ? event.which : event.keyCode;
          if (keyCode === KEY_ENTER) {
            act('submit', { entry: input });
          }



          // numpad subtract is broken tbw



          if (keyCode === KEY_ESCAPE) {
            act('cancel');
          }
          if (keyCode === KEY_BACKSPACE) {
            setInput(Math.floor(input / 10));
          }
          if (keyCode === KEY_NUMPAD_DECIMAL) {
            setInput(null);
          }
          if (keyCode >= KEY_0 && keyCode <= KEY_9) {
            const number = keyCode - KEY_0;
            onClick(number);
          }
          if (keyCode >= KEY_NUMPAD_0 && keyCode <= KEY_NUMPAD_9) {
            const number = keyCode - KEY_NUMPAD_0;
            onClick(number);
          }

        }}>
        <NoticeBox info>
          {message}
        </NoticeBox>
        <Section className="PINInput">
          <Stack.Item>
            <Stack fill>
              <Stack.Item>
                <div>Input: {input}</div>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack fill vertical>
            {Array.from({ length: 3 }, (_, index) => (
              <Stack.Item key={index}>
                <Stack fill>
                  {Array.from({ length: 3 }, (_, subIndex) => {
                    const number = index * 3 + subIndex + 1;
                    return (
                      <Stack.Item key={subIndex}>
                        <Button onClick={() => onClick(number)}>{number}</Button>
                      </Stack.Item>
                    );
                  })}
                </Stack>
              </Stack.Item>
            ))}
            <Stack.Item>
              <Stack fill>
                <Stack.Item>
                  <Button icon="circle-xmark" color="red" onClick={() => setInput(null)} />
                </Stack.Item>
                <Stack.Item>
                  <Button onClick={() => onClick(0)}>0</Button>
                </Stack.Item>
                <Stack.Item>
                  <Button icon="circle-right" color="green" onClick={() => act('submit', { entry: input })} />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

/** Gets the user input and invalidates if there's a constraint. */
const InputArea = (props, context) => {
  const { data } = useBackend<PINInputData>(context);
  const { input, onClick, onChange } = props;

  return (
    <Stack fill>
      <Stack.Item>
        <Button
          icon="angle-double-left"
          onClick={() => onClick(0)}
          tooltip="Minimum"
        />
      </Stack.Item>
      <Stack.Item grow>
        <NumberInput
          autoFocus
          autoSelect
          fluid
          onChange={(_, value) => onChange(value)}
          onDrag={(_, value) => onChange(value)}
          value={input !== null ? input : 0}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="angle-double-right"
          onClick={() => onClick(10000)}
          tooltip="Max"
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="redo"
          onClick={() => onClick(0)}
          tooltip="Reset"
        />
      </Stack.Item>
    </Stack>
  );
};
