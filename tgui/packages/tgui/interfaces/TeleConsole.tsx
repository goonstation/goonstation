/**
 * @file
 * @copyright 2023
 * @author Original Valtsu0 (https://github.com/Valtsu0)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { BooleanLike } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Box, Button, Icon, Input, LabeledList, Section } from '../components';

interface TeleConsoleData {
  xTarget: number;
  yTarget: number;
  zTarget: number;
  hostId: string;
  readout: string;
  isPanelOpen: BooleanLike;
  padNum: number;
  maxBookmarks: number;
  bookmarks: BookmarkData[];
}

interface BookmarkData {
  ref: string;
  name: string;
  x: number;
  y: number;
  z: number;
}

const formatCoordinates = (x: number, y: number, z: number) => `${x}, ${y}, ${z}`;

export const TeleConsole = (_props, context) => {
  const { act, data } = useBackend<TeleConsoleData>(context);
  const { xTarget, yTarget, zTarget, hostId, bookmarks, readout, isPanelOpen, padNum, maxBookmarks } = data;

  const handleAddBookmark = (name: string) => act('addbookmark', { value: name });
  const handleDeleteBookmark = (ref: string) => act('deletebookmark', { value: ref });
  const handleRestoreBookmark = (ref: string) => act('restorebookmark', { value: ref });

  return (
    <Window theme="ntos" width={400} height={500}>
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
        {readout && <Section>{readout}</Section>}
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

type BookmarksSectionProps = Pick<TeleConsoleData, 'bookmarks'> & {
  maxBookmarks: number;
  onAddBookmark: (name: string) => void;
  onDeleteBookmark: (ref: string) => void;
  onRestoreBookmark: (ref: string) => void;
  targetCoords: [number, number, number];
};

const BookmarksSection = (props: BookmarksSectionProps, context) => {
  const { bookmarks, maxBookmarks, onAddBookmark, onDeleteBookmark, onRestoreBookmark, targetCoords } = props;
  const [newBookmarkName, setNewBookmarkName] = useLocalState(context, 'newBookmarkName', '');
  const handleAddBookmark = (name: string) => {
    onAddBookmark(name);
    setNewBookmarkName('');
  };
  return (
    <Section title="Bookmarks">
      <LabeledList>
        {bookmarks.map((bookmark) => {
          return (
            <LabeledList.Item
              key={bookmark.ref}
              label={formatCoordinates(bookmark.x, bookmark.y, bookmark.z)}
              buttons={<Button icon="trash" color="red" onClick={() => onDeleteBookmark(bookmark.ref)} />}>
              <Button icon="bookmark" onClick={() => onRestoreBookmark(bookmark.ref)}>
                {bookmark.name}
              </Button>
            </LabeledList.Item>
          );
        })}
        {!!(bookmarks.length < maxBookmarks) && (
          <LabeledList.Item
            key="new"
            label={formatCoordinates(...targetCoords)}
            buttons={<Button icon="plus" color="green" onClick={() => handleAddBookmark(newBookmarkName)} />}>
            <Input
              width="100%"
              value={newBookmarkName}
              onInput={(_e, value: string) => setNewBookmarkName(value)}
              placeholder="New bookmark"
              onEnter={(_e, value: string) => handleAddBookmark(value)}
              maxLength={32}
            />
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};

const CoordinatesSection = (_props, context) => {
  const { act, data } = useBackend<TeleConsoleData>(context);
  const { xTarget, yTarget, zTarget } = data;

  return (
    <Section title="Target">
      <Box>
        {'X: '}
        <Button icon="backward" onClick={() => act('setX', { value: xTarget - 10 })} />
        <Button icon="caret-left" onClick={() => act('setX', { value: xTarget - 1 })} />
        <Button.Input content={xTarget} onCommit={(_e, value) => act('setX', { value: value })} />
        <Button icon="caret-right" onClick={() => act('setX', { value: xTarget + 1 })} />
        <Button icon="forward" onClick={() => act('setX', { value: xTarget + 10 })} />
      </Box>
      <Box>
        {'Y: '}
        <Button icon="backward" onClick={() => act('setY', { value: yTarget - 10 })} />
        <Button icon="caret-left" onClick={() => act('setY', { value: yTarget - 1 })} />
        <Button.Input content={yTarget} onCommit={(_e, value) => act('setY', { value: value })} />
        <Button icon="caret-right" onClick={() => act('setY', { value: yTarget + 1 })} />
        <Button icon="forward" onClick={() => act('setY', { value: yTarget + 10 })} />
      </Box>
      <Box>
        {'Z: '}
        <Button icon="caret-left" onClick={() => act('setZ', { value: zTarget - 1 })} />
        <Button.Input content={zTarget} onCommit={(_e, value) => act('setZ', { value: value })} />
        <Button icon="caret-right" onClick={() => act('setZ', { value: zTarget + 1 })} />
      </Box>
    </Section>
  );
};
