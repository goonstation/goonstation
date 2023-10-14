/**
 * @file
 * @copyright 2023
 * @author Original Valtsu0 (https://github.com/Valtsu0)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useBackend } from '../../backend';
import { Box, Button, Icon, Section } from '../../components';
import { Window } from '../../layouts';
import { BookmarksSection } from './BookmarksSection';
import { CoordinatesSection } from './CoordinatesSection';
import type { TeleConsoleData } from './types';
import { formatReadout } from './util';

export const TeleConsole = (_props, context) => {
  const { act, data } = useBackend<TeleConsoleData>(context);
  const { xTarget, yTarget, zTarget, hostId, bookmarks, readout, isPanelOpen, padNum, maxBookmarks } = data;

  const handleAddBookmark = (name: string) => act('addbookmark', { value: name });
  const handleDeleteBookmark = (ref: string) => act('deletebookmark', { value: ref });
  const handleRestoreBookmark = (ref: string) => act('restorebookmark', { value: ref });

  return (
    <Window theme="ntos" width={400} height={510}>
      <Window.Content textAlign="center">
        <CoordinatesSection />
        <Section>
          <Button color="green" icon="sign-out-alt" onClick={() => act('send')} disabled={!hostId}>
            Send
          </Button>
          <Button color="green" icon="sign-in-alt" onClick={() => act('receive')} disabled={!hostId}>
            Receive
          </Button>
          <Button color="green" onClick={() => act('portal')} disabled={!hostId}>
            <Icon name="ring" rotation={90} />
            Toggle Portal
          </Button>
          <Button color="green" icon="magnifying-glass" onClick={() => act('scan')} disabled={!hostId}>
            Scan
          </Button>
        </Section>
        {readout && <Section>{formatReadout(readout)}</Section>}
        <BookmarksSection
          bookmarks={bookmarks}
          maxBookmarks={maxBookmarks}
          onAddBookmark={handleAddBookmark}
          onDeleteBookmark={handleDeleteBookmark}
          onRestoreBookmark={handleRestoreBookmark}
          targetCoords={[xTarget, yTarget, zTarget]}
        />
        {!!isPanelOpen && (
          <Section>
            <Box>Open panel:</Box>
            <Box>
              Linked pad number:
              <Button content={padNum} onClick={() => act('setpad')} />
            </Box>
          </Section>
        )}
        <ConnectionSection />
      </Window.Content>
    </Window>
  );
};

const ConnectionSection = (_props, context) => {
  const { act, data } = useBackend<TeleConsoleData>(context);
  const { hostId } = data;

  return (
    <Section>
      {hostId ? (
        <Box color="green">
          <Box>
            <Icon name="check" /> Connected to host!
          </Box>
          <Button
            icon="power-off"
            content="RESET CONNECTION"
            color="red"
            onClick={() => act('reconnect', { value: 2 })}
          />
        </Box>
      ) : (
        <Box color="red">
          <Box>
            <Icon name="warning" /> No connection to host!
          </Box>
          <Button icon="power-off" content="Retry" color="green" onClick={() => act('reconnect', { value: 1 })} />
        </Box>
      )}
    </Section>
  );
};
