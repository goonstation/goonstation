/**
 * @file
 * @copyright 2023
 * @author Garash2k (https://github.com/garash2k)
 * @license ISC
 */

import { useCallback, useEffect, useState } from 'react';
import { Button, Flex, Section, Tooltip } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { TerminalInput } from './TerminalInput';
import type { TerminalData } from './types';

export const InputAndButtonsSection = () => {
  const { act, data } = useBackend<TerminalData>();
  const { TermActive, inputValue, ckey } = data;

  const [localInputValue, setLocalInputValue] = useState(inputValue);

  const setDOMInputValue = (value) => {
    // In theory, only calling setLocalInputValue(...) should work, but it doesn't, and requires the below hack to work.
    // I think the cause of this is the useEffect() in tgui's Input.tsx. I couldn't find a workaround.
    const domInput = document.querySelector(
      ".terminalInput input[class^='_inner']",
    );
    if (domInput) {
      (domInput as HTMLInputElement).value = value;
    }
  };

  const handleInputEnter = useCallback(
    (_e, value) => act('text', { value: value, ckey: ckey }),
    [act, ckey],
  );
  const handleEnterClick = useCallback(() => {
    act('text', { value: localInputValue, ckey: ckey });
    setLocalInputValue('');
    setDOMInputValue('');
  }, [act, ckey, localInputValue]);
  const handleHistoryPrevious = useCallback(
    () => act('history', { direction: 'prev', ckey: ckey }),
    [act, ckey],
  );
  const handleHistoryNext = useCallback(
    () => act('history', { direction: 'next', ckey: ckey }),
    [act, ckey],
  );
  const handleInputChange = useCallback(
    (_e, value) => setLocalInputValue(value),
    [],
  );
  const handleRestartClick = useCallback(() => act('restart'), [act]);

  // When inputValue changes, it means a history event happened, so only then should we erase local input value with what was received from the server.
  useEffect(() => {
    setLocalInputValue(inputValue);
    setDOMInputValue(inputValue);
  }, [inputValue]);

  return (
    <Section fitted>
      <Flex align="center">
        <Flex.Item grow>
          <TerminalInput
            autoFocus
            value={localInputValue}
            className="terminalInput"
            placeholder="Type Here"
            selfClear
            fluid
            mr="0.5rem"
            onKeyUp={handleHistoryPrevious}
            onKeyDown={handleHistoryNext}
            onEnter={handleInputEnter}
            onChange={handleInputChange}
          />
        </Flex.Item>
        <Flex.Item>
          <Tooltip content="Enter">
            <Button
              icon="share"
              color={TermActive ? 'positive' : 'negative'}
              onClick={handleEnterClick}
              mr="0.5rem"
              my={0.25}
            />
          </Tooltip>
        </Flex.Item>
        <Flex.Item>
          <Tooltip content="Restart">
            <Button
              icon="repeat"
              color={TermActive ? 'positive' : 'negative'}
              onClick={handleRestartClick}
              my={0.25}
            />
          </Tooltip>
        </Flex.Item>
      </Flex>
    </Section>
  );
};
