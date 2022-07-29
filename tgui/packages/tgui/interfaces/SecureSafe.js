/**
 * @file
 * @copyright 2022
 * @author blackrep (https://github.com/blackrep)
 * @license MIT
 */


import { useBackend } from '../backend';
import { Stack, Box, ProgressBar, Section, Flex, Button, Blink } from '../components';
import { Window } from '../layouts';

import { capitalize, glitch } from './common/stringUtils';

const KEY_PAD_INPUT_LAYOUT = [
  ['7', '8', '9', 'A'],
  ['4', '5', '6', 'B'],
  ['1', '2', '3', 'C'],
  ['0', 'F', 'E', 'D'],
];

const stylizeCode = (attempt, codeLen) => {
  return attempt.padEnd(codeLen, "*").split("").join(" ");
};

const SecureSafeScreen = (props, _context) => {
  const {
    attempt,
    codeLen,
    disabled,
    emagged,
    padMsg,
  } = props;

  let content = padMsg ? padMsg : stylizeCode(attempt, codeLen);
  if (disabled) {
    content = "NO ACCESS";
  }
  if (emagged) {
    content = glitch(content, 2);
  }
  return (
    <Box
      fontSize="25px"
      fontFamily="Courier"
      bold
      textAlign="center"
      padding="3px"
      backgroundColor="#342210"
      style={{
        "border-width": "0.1em",
        "border-style": "solid",
        "border-radius": "0.16em",
        "border-color": "#FC8E1F",
      }}
    >
      {content}
    </Box>
  );
};

const SecureSafeKeyPad = (props, _context) => {
  const {
    act,
  } = props;

  return (
    <>
      <Flex.Item>
        {KEY_PAD_INPUT_LAYOUT.map((row, rowIndex) => {
          const rowLen = row.length;
          return (
            <Flex
              key={`row-${rowIndex}`}
              justify="space-between"
              mt={1}
            >
              {row.map((input, colIndex) => {
                return (
                  <Flex.Item
                    key={input}
                    grow={1}
                    mr={colIndex < rowLen - 1 ? 1 : 0}
                  >
                    <Button
                      fluid
                      textAlign="center"
                      fontSize="25px"
                      fontFamily="Courier"
                      bold
                      content={input}
                      onClick={() => act('input', { input })}
                    />
                  </Flex.Item>
                );
              })}
            </Flex>
          );
        })}
      </Flex.Item>
      <Flex.Item mt={1}>
        <Flex justify="space-between">
          <Flex.Item grow={1} mr={1}>
            <Button
              fluid
              textAlign="center"
              fontSize="20px"
              fontFamily="Courier"
              bold
              content="ENTER"
              onClick={() => act('enter')}
            />
          </Flex.Item>
          <Flex.Item grow={1}>
            <Button
              fluid
              textAlign="center"
              fontSize="20px"
              fontFamily="Courier"
              bold
              content="RESET"
              onClick={() => act('reset')}
            />
          </Flex.Item>
        </Flex>
      </Flex.Item>
    </>
  );
};

export const SecureSafe = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    attempt,
    codeLen,
    disabled,
    emagged,
    padMsg,
    safeName,
  } = data;
  return (
    <Window
      title={capitalize(safeName)}
      width={200}
      height={328}
      theme="retro-dark"
    >
      <Window.Content>
        <Section fill>
          <Stack vertical>
            <SecureSafeScreen
              attempt={attempt}
              codeLen={codeLen}
              disabled={disabled}
              emagged={emagged}
              padMsg={padMsg}
            />
            <SecureSafeKeyPad act={act} />
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
