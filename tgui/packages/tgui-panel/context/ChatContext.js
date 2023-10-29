/**
 * @file
 * @copyright 2023
 * @author Cheffie
 * @link https://github.com/CheffieGithub
 * @license MIT
 */

import { sendMessage } from 'tgui/backend';
import { Button, Section, Stack } from 'tgui/components';
import { CONTEXT_ITEMS } from './constants';
import { selectContext } from './selectors';
import { useSelector } from 'common/redux';
import { chatRenderer } from '../chat/renderer';


export const ContextMenu = (props, context) => {
  const {
    contextFlags,
    contextTarget,
    contextName,
  } = useSelector(context, selectContext);
  return (
    <div className="Chat__contextMenu">
      <span className="Chat__contextMenu--title">{contextName}</span>
      <Section>
        <Stack allign="left">
          <Stack.Item grow={1}>
            {CONTEXT_ITEMS
              .filter(typeDef => typeDef.flag & contextFlags)
              .map(typeDef => (
                <Button
                  key={typeDef.type}
                  tooltip={typeDef.description}
                  className="Chat__contextMenu--inside"
                  tooltipPosition="right"
                  onClick={() => contextMenuAct(typeDef.type, contextTarget)}>
                  {typeDef.name}
                </Button>
              ))}
            <Button
              className="Chat__contextMenu--inside"
              onClick={() => chatRenderer.events.emit('contextShow', false)}>
              Close menu
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
    </div>
  );
};

const contextMenuAct = (command, target) => {
  sendMessage({
    type: 'contextact',
    payload: {
      command,
      target,
    },
  });
  return;
};
