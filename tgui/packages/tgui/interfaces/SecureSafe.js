import { useBackend } from '../backend';
import { Stack, Box, ProgressBar, Section, Flex, Button } from '../components';
import { Window } from '../layouts';

import { capitalize } from './common/stringUtils';

const stylizeText = (text) => {
  return text.split("").join(" ");
};

const SecureSafeScreen = (props, _context) => {
  const {
    input,
  } = props;
  return (
    // Crude hack to get the styling I want
    <ProgressBar
      fontSize="25px"
    >
      <Box
        fontFamily="Courier"
        bold
        textAlign="center"
      >
        {stylizeText(input)}
      </Box>
    </ProgressBar>
  );
};

const KEY_PAD_INPUT_LAYOUT = [
  ['7', '8', '9', 'A'],
  ['4', '5', '6', 'B'],
  ['1', '2', '3', 'C'],
  ['0', 'F', 'E', 'D'],
];

const SecureSafeKeyPad = (_props, _context) => {
  return (
    <>
      <Flex.Item>
        {KEY_PAD_INPUT_LAYOUT.map((row, rowIndex) => {
          const rowLen = row.length;
          return (
            <Flex justify="space-between" key={`row-${rowIndex}`} mt={1}>
              {row.map((input, colIndex) => {
                return (
                  <Flex.Item key={input} grow={1} mr={colIndex < rowLen - 1 ? 1 : 0}>
                    <Button textAlign="center" fluid fontSize="25px" fontFamily="Courier" bold content={input} />
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
            <Button textAlign="center" fluid fontSize="20px" fontFamily="Courier" bold content="ENTER" />
          </Flex.Item>
          <Flex.Item grow={1}>
            <Button textAlign="center" fluid fontSize="20px" fontFamily="Courier" bold content="RESET" />
          </Flex.Item>
        </Flex>
      </Flex.Item>
    </>
  );
};

export const SecureSafe = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    safeName,
  } = data;
  const input = "A***";
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
            <SecureSafeScreen input={input} />
            <SecureSafeKeyPad />
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
