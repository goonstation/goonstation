/**
 * @file
 * @copyright 2024
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license MIT
 */

import { useState } from 'react';
import {
  Autofocus,
  Button,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import {
  KEY_0,
  KEY_9,
  KEY_BACKSPACE,
  KEY_ENTER,
  KEY_ESCAPE,
  KEY_NUMPAD_0,
  KEY_NUMPAD_9,
  KEY_NUMPAD_DECIMAL,
} from '../../common/keycodes';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Loader } from './common/Loader';

type PINInputData = {
  message: string;
  max_value: number | null;
  min_value: number | null;
  init_value: number | null;
  timeout: number;
  title: string;
  theme: string;
};

export const PINInputModal = () => {
  const { act, data } = useBackend<PINInputData>();
  const { message, init_value, min_value, max_value, timeout, title, theme } =
    data;
  const [pin, setPin] = useState(setupPinState(init_value));
  const [giveWarning, setGiveWarning] = useState(false);

  const onClick = (value: number) => {
    // If the pin is less than 4 digits, add the new digit to the right.
    if (pin.length < 4) {
      setPin([...pin, value]);
    } else {
      // Otherwise, replace the rightmost digit with the new digit.
      setPin([...pin.slice(0, -1), value]);
    }
  };

  const handleSubmission = () => {
    if (pin.length < 4) {
      return;
    }
    if (
      (min_value !== null && pinToNumber(pin) < min_value) ||
      (max_value !== null && pinToNumber(pin) > max_value)
    ) {
      setGiveWarning(true);
      setPin([]);
      return;
    }
    act('submit', { entry: pin });
  };

  return (
    <Window
      title={title}
      width={160}
      height={giveWarning ? 345 : 315}
      theme={theme || 'nanotrasen'}
    >
      {timeout && <Loader value={timeout} />}
      <Window.Content
        onKeyDown={(event) => {
          const keyCode = window.event ? event.which : event.keyCode;
          if (keyCode === KEY_ENTER) {
            handleSubmission();
          } else if (keyCode === KEY_ESCAPE) {
            act('cancel');
          } else if (keyCode === KEY_BACKSPACE) {
            setPin(pin.slice(0, -1));
          } else if (keyCode === KEY_NUMPAD_DECIMAL) {
            setPin([]);
          } else if (keyCode >= KEY_0 && keyCode <= KEY_9) {
            const number = keyCode - KEY_0;
            onClick(number);
          } else if (keyCode >= KEY_NUMPAD_0 && keyCode <= KEY_NUMPAD_9) {
            const number = keyCode - KEY_NUMPAD_0;
            onClick(number);
          }
        }}
      >
        <Autofocus />
        {giveWarning ? (
          <NoticeBox danger>
            The PIN you entered is outside the valid range of {min_value}-
            {max_value}.
          </NoticeBox>
        ) : (
          <NoticeBox info>{message}</NoticeBox>
        )}
        <Section className="PINInput">
          <Stack fill className="PINInput__Stack" mb={1}>
            <div className="PINInput__display">
              {/* Display 4 digits, if empty show underscores */}
              {Array.from({ length: 4 }, (_, index) => {
                const digit = pin[index];
                return (
                  <span key={index} className="PINInput__digit">
                    {digit === undefined ? '_' : digit}
                  </span>
                );
              })}
            </div>
          </Stack>
          <Stack fill vertical>
            {Array.from({ length: 3 }, (_, index) => (
              <Stack.Item key={index}>
                <Stack fill>
                  {Array.from({ length: 3 }, (_, subIndex) => {
                    const number = index * 3 + subIndex + 1;
                    return (
                      <Stack.Item key={subIndex} grow>
                        <Button
                          className="PINInput__button"
                          onClick={() => onClick(number)}
                        >
                          {number}
                        </Button>
                      </Stack.Item>
                    );
                  })}
                </Stack>
              </Stack.Item>
            ))}
            <Stack.Item>
              <Stack fill>
                <Stack.Item grow>
                  <Button
                    icon="circle-xmark"
                    className="PINInput__button"
                    color="red"
                    onClick={() => setPin([])}
                  />
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    className="PINInput__button"
                    onClick={() => onClick(0)}
                  >
                    0
                  </Button>
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    icon="circle-right"
                    iconPosition="center"
                    className="PINInput__button"
                    color="green"
                    onClick={handleSubmission}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

const setupPinState = (init_value: number | null): number[] => {
  if (init_value === null) {
    return [];
  }
  const arr = Array(4);
  for (let i = 0; i < 4; i++) {
    arr[i] = Math.floor(init_value / 10 ** (3 - i)) % 10;
  }
  return arr;
};

const pinToNumber = (pin: number[]) => {
  return pin.reduce((acc, digit, index) => {
    return acc + digit * 10 ** (3 - index);
  }, 0);
};
