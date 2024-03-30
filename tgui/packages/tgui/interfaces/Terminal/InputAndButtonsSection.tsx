/**
 * @file
 * @copyright 2023
 * @author Garash2k (https://github.com/garash2k)
 * @license ISC
 */

import { useBackend } from '../../backend';
import { TerminalData } from './types';
import { Button, Flex, Input, Section, Tooltip } from '../../components';

export const InputAndButtonsSection = (_props, context) => {
  const { act, data } = useBackend<TerminalData>(context);
  const {
    TermActive,
  } = data;

  const handleInputEnter = (_e, value) => {
    act('text', { value: value });
  };
  const handleEnterClick = () => {
    // Still a tiny bit hacky but it's a manual click on the enter button which already caused me too much grief
    const domInput = document.querySelector('#terminalInput .Input__input') as HTMLInputElement;
    act('text', { value: domInput.value });
    domInput.value = '';
  };
  const handleRestartClick = () => act('restart');

  return (
    <Section fitted>
      <Flex align="center">
        <Flex.Item grow>
          <Input
            id="terminalInput"
            placeholder="Type Here"
            selfClear
            fluid
            mr="0.5rem"
            onEnter={handleInputEnter}
            history
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
