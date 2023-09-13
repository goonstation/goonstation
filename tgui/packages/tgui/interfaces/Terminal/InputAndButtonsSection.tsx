/**
 * @file
 * @copyright 2023
 * @author Garash2k (https://github.com/garash2k)
 * @license ISC
 */

import { useBackend, useLocalState } from '../../backend';
import { TerminalData } from './types';
import { Section, Flex, Input, Tooltip, Button } from '../../components';

export const InputAndButtonsSection = (_props, context) => {
  const { act, data } = useBackend<TerminalData>(context);
  const {
    TermActive,
  } = data;

  const [textInput, setTextInput] = useLocalState(context, 'textInput', "");
  const [textInputHistory, setTextInputHistory] = useLocalState(context, 'textInputHistory', []);
  const [textInputHistoryIndex, setTextInputHistoryIndex] = useLocalState(context, 'textInputHistoryIndex', 0);

  const navigateHistory = function (direction, DOMInput) {
    const newIndex = textInputHistoryIndex + direction;
    let hasMoreHistory = false;
    if (direction > 0 && newIndex < textInputHistory.length) {
      hasMoreHistory = true;
    } else if (direction < 0 && newIndex >= 0) {
      hasMoreHistory = true;
    }
    if (hasMoreHistory) {
      setTextInput(textInputHistory[newIndex]);
      // setTextInput *should* have been good enough but sometimes, after editing the input, it fails to update,
      // so let's update the dom input directly just to be sure
      DOMInput.value = textInputHistory[newIndex];
      setTextInputHistoryIndex(newIndex);
    } else if (direction > 0) {
      // The last down arrow should clear the text field
      setTextInput("");
      DOMInput.value = "";
      setTextInputHistoryIndex(textInputHistory.length);
    }
  };

  const appendHistory = function (newText) {
    if (textInputHistory[textInputHistory.length - 1] === newText) {
      return;
    }
    textInputHistory.push(newText);
    setTextInputHistory(textInputHistory);
    setTextInputHistoryIndex(textInputHistoryIndex + 1);
  };

  const handleInputInput = (_e, value) => {
    setTextInput(value);
    setTextInputHistoryIndex(textInputHistory.length);
  };
  const handleInputKeydown = (e) => {
    if (e.key === 'Enter') {
      act('text', { value: textInput });
      appendHistory(textInput);
      setTextInput("");
    } else if (e.key === 'Up') {
      navigateHistory(-1, e.target);
    } else if (e.key === 'Down') {
      navigateHistory(1, e.target);
    }
  };
  const handleEnterClick = () => {
    act('text', { value: textInput });
    appendHistory(textInput);
    setTextInput("");
  };
  const handleRestartClick = () => act('restart');

  return (
    <Section fitted>
      <Flex align="center">
        <Flex.Item grow>
          <Input
            as="span"
            placeholder="Type Here"
            selfClear
            value={textInput}
            fluid
            onInput={handleInputInput}
            onKeyDown={handleInputKeydown}
            mr="0.5rem"
          />
        </Flex.Item>
        <Flex.Item>
          <Tooltip content="Enter">
            <Button icon="share"
              color={TermActive ? "green" : "red"}
              onClick={handleEnterClick}
              mr="0.5rem"
              my={0.25} />
          </Tooltip>
        </Flex.Item>
        <Flex.Item>
          <Tooltip content="Restart">
            <Button icon="repeat"
              color={TermActive ? "green" : "red"}
              onClick={handleRestartClick}
              my={0.25} />
          </Tooltip>
        </Flex.Item>
      </Flex>
    </Section>
  );
};
