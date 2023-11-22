/**
 * @file
 * @copyright 2023
 * @author Cheffie
 * @link https://github.com/CheffieGithub
 * @license MIT
 */

import { sendMessage } from 'tgui/backend';
import { Box, Button, Section, Stack } from 'tgui/components';
import { CONTEXT_ITEMS } from './constants';
import { selectContext } from './selectors';
import { useSelector } from 'common/redux';

export const ContextMenu = (props, context) => {
  const {
    contextFlags,
    contextTarget,
    contextName,
  } = useSelector(context, selectContext);
  return (
    <Box className="Chat__contextMenu">
      <Section fill vertical>
        <Box as="span" className="Chat__contextMenu--title">{contextName}</Box>
        <Stack>
          <Stack.Item grow>
            {CONTEXT_ITEMS
              .filter(typeDef => typeDef.flag & contextFlags)
              .map(typeDef => (
                <Button
                  key={typeDef.type}
                  tooltip={typeDef.description}
                  className="Chat__contextMenu--item"
                  tooltipPosition="right"
                  onClick={() => contextMenuAct(typeDef.type, contextTarget)}>
                  {typeDef.name}
                </Button>
              ))}
          </Stack.Item>
        </Stack>
      </Section>
    </Box>
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
