/**
 * @file
 * @copyright 2023
 * @author Original Garash2k (https://github.com/garash2k)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useCallback, useState } from 'react';
import { Button, Input, Section, Stack, Tooltip } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { createLogger } from '../../logging';
import type { TerminalData } from './types';

const logger = createLogger('inputbuttonssection');

export const InputAndButtonsSection = () => {
  const { act, data } = useBackend<TerminalData>();
  const { TermActive, ckey } = data;

  const [localInputValue, setLocalInputValue] = useState('');
  // renderKey used to force input to remount, triggering autoFocus
  const [renderKey, setRenderKey] = useState(0);
  const incrementRenderKey = useCallback(
    () => setRenderKey((prev) => prev + 1),
    [],
  );

  const handleEnter = useCallback(
    (value: string) => {
      act('text', { value, ckey });
      setLocalInputValue('');
      incrementRenderKey();
    },
    [act, ckey, incrementRenderKey],
  );
  const handleEnterClick = useCallback(() => {
    act('text', { value: localInputValue, ckey });
    setLocalInputValue('');
    incrementRenderKey();
  }, [act, ckey, incrementRenderKey, localInputValue]);
  const handleChange = useCallback(
    (value: string) => setLocalInputValue(value),
    [],
  );
  const handleRestartClick = useCallback(() => {
    act('restart');
    setLocalInputValue('');
    incrementRenderKey();
  }, [act, incrementRenderKey]);

  return (
    <Section fitted>
      <Stack verticalAlign="center">
        <Stack.Item grow>
          <Input
            autoFocus
            key={renderKey}
            value={localInputValue}
            placeholder="Type Here"
            fluid
            onEnter={handleEnter}
            onChange={handleChange}
          />
        </Stack.Item>
        <Stack.Item>
          <Tooltip content="Enter">
            <Button
              icon="share"
              // disabled={!TermActive}
              color={!TermActive ? 'transparent' : 'default'}
              onClick={handleEnterClick}
            />
          </Tooltip>
        </Stack.Item>
        <Stack.Item>
          <Tooltip content="Restart">
            <Button
              icon="repeat"
              // disabled={!TermActive}
              color={!TermActive ? 'transparent' : 'default'}
              onClick={handleRestartClick}
            />
          </Tooltip>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
