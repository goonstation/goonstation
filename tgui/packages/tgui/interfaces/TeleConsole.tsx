/**
 * @file
 * @copyright 2023
 * @author Original Valtsu0 (https://github.com/Valtsu0)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Box, Button, Icon, Input, LabeledList, Section } from '../components';

interface TeleConsoleData {
  xtarget: number;
  ytarget: number;
  ztarget: number;
  host_id: string;
  readout: string;
  panel_open: boolean;
  padNum: number;
  max_bookmarks: number;
  bookmarks: BookmarkData[];
}

interface BookmarkData {
  ref: string;
  name: string;
  X: number;
  Y: number;
  Z: number;
}

const formatCoordinates = (x: number, y: number, z: number) => `${x}, ${y}, ${z}`;

export const TeleConsole = (_props, context) => {
  const { act, data } = useBackend<TeleConsoleData>(context);
  const [newBookmarkName, setNewBookmarkName] = useLocalState(context, 'newBookmarkName', '');
  const { xtarget, ytarget, ztarget, host_id, bookmarks, readout, panel_open, padNum, max_bookmarks } = data;

  const handleAddBookmark = (name: string) => {
    act('addbookmark', { value: name });
    setNewBookmarkName('');
  };
  return (
    <Window theme="ntos" width={400} height={500}>
      <Window.Content textAlign="center">
        {readout && <Section>{readout}</Section>}
        <CoordinatesSection />
        <Section>
          <Box>
            <Button color="green" icon="sign-out-alt" onClick={() => act('send')} disabled={!host_id}>
              Send
            </Button>
            <Button color="green" icon="sign-in-alt" onClick={() => act('receive')} disabled={!host_id}>
              Receive
            </Button>
            <Button color="green" onClick={() => act('portal')} disabled={!host_id}>
              <Icon name="ring" rotation={90} />
              Toggle Portal
            </Button>
          </Box>
          <Button color="green" icon="magnifying-glass" onClick={() => act('scan')} disabled={!host_id}>
            Scan
          </Button>
        </Section>
        <Section title="Bookmarks">
          <LabeledList>
            {bookmarks.map((bookmark) => {
              return (
                <LabeledList.Item
                  key={bookmark.ref}
                  label={formatCoordinates(bookmark.X, bookmark.Y, bookmark.Z)}
                  buttons={
                    <Button icon="trash" color="red" onClick={() => act('deletebookmark', { value: bookmark.ref })} />
                  }>
                  <Button icon="bookmark" onClick={() => act('restorebookmark', { value: bookmark.ref })}>
                    {bookmark.name}
                  </Button>
                </LabeledList.Item>
              );
            })}
            {!!(bookmarks.length < max_bookmarks) && (
              <LabeledList.Item
                key="new"
                label={formatCoordinates(xtarget, ytarget, ztarget)}
                buttons={<Button icon="plus" color="green" onClick={() => handleAddBookmark(newBookmarkName)} />}>
                <Input
                  width="100%"
                  value={newBookmarkName}
                  onInput={(_e, value) => setNewBookmarkName(value)}
                  placeholder="New bookmark"
                  onEnter={(_e, value) => handleAddBookmark(value)}
                />
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
        {!!panel_open && (
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
  const { host_id } = data;

  return (
    <Section>
      {host_id ? (
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

const CoordinatesSection = (_props, context) => {
  const { act, data } = useBackend<TeleConsoleData>(context);
  const { xtarget, ytarget, ztarget } = data;

  return (
    <Section title="Target">
      <Box>
        {'X: '}
        <Button icon="backward" onClick={() => act('setX', { value: xtarget - 10 })} />
        <Button icon="caret-left" onClick={() => act('setX', { value: xtarget - 1 })} />
        <Button.Input content={xtarget} onCommit={(e, value) => act('setX', { value: value })} />
        <Button icon="caret-right" onClick={() => act('setX', { value: xtarget + 1 })} />
        <Button icon="forward" onClick={() => act('setX', { value: xtarget + 10 })} />
      </Box>
      <Box>
        {'Y: '}
        <Button icon="backward" onClick={() => act('setY', { value: ytarget - 10 })} />
        <Button icon="caret-left" onClick={() => act('setY', { value: ytarget - 1 })} />
        <Button.Input content={ytarget} onCommit={(e, value) => act('setY', { value: value })} />
        <Button icon="caret-right" onClick={() => act('setY', { value: ytarget + 1 })} />
        <Button icon="forward" onClick={() => act('setY', { value: ytarget + 10 })} />
      </Box>
      <Box>
        {'Z: '}
        <Button icon="caret-left" onClick={() => act('setZ', { value: ztarget - 1 })} />
        <Button.Input content={ztarget} onCommit={(e, value) => act('setZ', { value: value })} />
        <Button icon="caret-right" onClick={() => act('setZ', { value: ztarget + 1 })} />
      </Box>
    </Section>
  );
};
