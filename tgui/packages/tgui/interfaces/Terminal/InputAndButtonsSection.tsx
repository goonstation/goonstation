/**
 * @file
 * @copyright 2023
 * @author Garash2k (https://github.com/garash2k)
 * @license ISC
 */

import { Button, Flex, Input, Section, Tooltip } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { TerminalData } from './types';

export const InputAndButtonsSection = () => {
  const { act, data } = useBackend<TerminalData>();
  const { TermActive } = data;

  const handleInputEnter = (_e, value) => {
    act('text', { value: value });
  };
  const handleEnterClick = () => {
    // Still a tiny bit hacky but it's a manual click on the enter button which already caused me too much grief
    const domInput = document.querySelector(
      ".terminalInput input[class^='_inner']",
    ) as HTMLInputElement;
    act('text', { value: domInput.value });
    domInput.value = '';
  };
  const handleRestartClick = () => act('restart');

  return (
    <Section fitted>
      <Flex align="center">
        <Flex.Item grow>
          <Input
            className="terminalInput"
            placeholder="Type Here"
            selfClear
            fluid
            mr="0.5rem"
            onEnter={handleInputEnter}
            // TODO-REACT: re-implement up/down arrow `history` functionallity
          />
        </Flex.Item>
        <Flex.Item>
          <Tooltip content="Enter">
            <Button
              icon="share"
              color={TermActive ? 'green' : 'red'}
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
              color={TermActive ? 'green' : 'red'}
              onClick={handleRestartClick}
              my={0.25}
            />
          </Tooltip>
        </Flex.Item>
      </Flex>
    </Section>
  );
};
