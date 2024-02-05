/**
 * @file
 * @copyright 2024
 * @author ZeWaka (https://github.com/zewaka)
 * @license MIT
 */

import { Loader } from './common/Loader';
import { useBackend } from '../backend';
import { Box, Section } from '../components';
import { Window } from '../layouts';
import { KEY_ESCAPE } from 'common/keycodes';
import { sanitizeDefAllowTags, sanitizeText } from '../sanitize';

type MessageInputData = {
  message: string;
  timeout: number;
  title: string;
  theme: string;
  sanitize: boolean;
};

export const MessageModal = (_, context) => {
  const { act, data } = useBackend<MessageInputData>(context);
  const { message, timeout, title, theme, sanitize } = data;
  // Dynamically changes the window height based on the message.
  const windowHeight
    = 125 + Math.ceil(message?.length / 3);

  let outputMessage = message;
  if (sanitize) {
    let allowedHTMLTags = sanitizeDefAllowTags;
    allowedHTMLTags.push('a'); // We commonly want to let users redirect to a URL.
    let forbiddenHTMLTags = []; // sanitizeDefForbiddenTags - I don't see a reason to forbid styling for this
    outputMessage = sanitizeText(message, allowedHTMLTags, forbiddenHTMLTags);
  }


  return (
    <Window title={title} width={300} height={windowHeight} theme={theme || 'nanotrasen'}>
      {timeout && <Loader value={timeout} />}
      <Window.Content
        onKeyDown={(event) => {
          const keyCode = window.event ? event.which : event.keyCode;
          if (keyCode === KEY_ESCAPE) {
            act('close');
          }
        }}
      >
        <Section scrollable fill>
          <Box color="label" dangerouslySetInnerHTML={{ __html: outputMessage }} />
        </Section>
      </Window.Content>
    </Window>
  );
};

