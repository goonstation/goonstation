/**
 * @file
 * @copyright 2024
 * @author ZeWaka (https://github.com/zewaka)
 * @license MIT
 */

import { KEY_ESCAPE } from 'common/keycodes';
import { Box, Section } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { sanitizeDefAllowTags, sanitizeText } from '../sanitize';
import { Loader } from './common/Loader';

type MessageInputData = {
  message: string;
  title: string;
  timeout: number;
  width: number;
  height: number;
  theme: string;
  sanitize: BooleanLike;
};

export const MessageModal = () => {
  const { act, data } = useBackend<MessageInputData>();
  const { message, title, timeout, width, height, theme, sanitize } = data;
  const windowWidth = width ? width : 300;
  // Dynamically changes the window height based on the message.
  const windowHeight = height ? height : 125 + Math.ceil(message?.length / 3);

  let outputMessage = message;
  if (sanitize) {
    const allowedHTMLTags = [...sanitizeDefAllowTags, 'a']; // We commonly want to let users redirect to a URL.
    const forbiddenHTMLTags = []; // sanitizeDefForbiddenTags - I don't see a reason to forbid styling for this
    outputMessage = sanitizeText(
      message,
      false,
      allowedHTMLTags,
      forbiddenHTMLTags,
    );
  }

  return (
    <Window
      title={title}
      width={windowWidth}
      height={windowHeight}
      theme={theme || 'nanotrasen'}
    >
      {(timeout && <Loader value={timeout} />) || null}
      <Window.Content
        onKeyDown={(event) => {
          const keyCode = window.event ? event.which : event.keyCode;
          if (keyCode === KEY_ESCAPE) {
            act('close');
          }
        }}
      >
        <Section scrollable fill>
          <Box
            color="label"
            dangerouslySetInnerHTML={{ __html: outputMessage }}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
