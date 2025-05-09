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

  const handleInputEnter = useCallback(
    (value: string) => act('text', { value, ckey }),
    [act, ckey],
  );
  const handleEnterClick = useCallback(() => {
    act('text', { value: localInputValue, ckey });
    setLocalInputValue('');
  }, [act, ckey, localInputValue]);
  const handleHistoryPrevious = useCallback(
    () => act('history', { direction: 'prev', ckey }),
    [act, ckey],
  );
  const handleHistoryNext = useCallback(
    () => act('history', { direction: 'next', ckey }),
    [act, ckey],
  );
  const handleInputChange = useCallback(
    (value: string) => setLocalInputValue(value),
    [],
  );
  const handleRestartClick = useCallback(() => act('restart'), [act]);

  // When inputValue changes, it means a history event happened, so only then should we erase local input value with what was received from the server.
  useEffect(() => {
    setLocalInputValue(inputValue);
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
            onUpPressed={handleHistoryPrevious}
            onDownPressed={handleHistoryNext}
            onEnter={handleInputEnter}
            onBlur={handleInputChange}
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
