/**
 * @file
 * @copyright 2022-2023
 * @author Original skeletonman0 (https://github.com/skeletonman0/)
 * @author Changes garash2k (https://github.com/garash2l)
 * @license MIT
 */

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { TerminalData } from './types';
import { TerminalOutputSection } from './TerminalOutputSection';
import { InputAndButtonsSection } from './InputAndButtonsSection';
import { PheripheralsSection } from './PheripheralsSection';
import { Stack } from '../../components';

export const Terminal = (_props, context) => {
  const { data } = useBackend<TerminalData>(context);
  const {
    windowName,
    displayHTML,
  } = data;

  const handleTerminalOutputComponentDidUpdate = (lastProps, nextProps) => {
    if (lastProps.displayHTML === nextProps.displayHTML) {
      return;
    }
    scrollToBottom();
  };
  const scrollToBottom = () => {
    const terminalOutputScroll = document.querySelector('#terminalOutput .Section__content');
    if (!terminalOutputScroll) {
      return;
    }
    terminalOutputScroll.scrollTop = terminalOutputScroll.scrollHeight;
  };

  return (
    <Window
      theme="retro-dark"
      title={windowName}
      fontFamily="Consolas"
      width="380"
      height="350">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <TerminalOutputSection
              displayHTML={displayHTML}
              onComponentDidMount={scrollToBottom}
              onComponentDidUpdate={handleTerminalOutputComponentDidUpdate} />
          </Stack.Item>
          <Stack.Item>
            <InputAndButtonsSection />
          </Stack.Item>
          <Stack.Item>
            <PheripheralsSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
