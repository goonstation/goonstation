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
import { Box, Button, Icon, Input, LabeledList, Section, Slider, Stack } from '../components';
import { clamp, toFixed } from 'common/math';
import { decodeHtmlEntities } from 'common/string';

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

const formatDecimal = (value: number) => toFixed(value, 2);
const formatCoordinates = (x: number, y: number, z: number) => `${formatDecimal(x)}, ${formatDecimal(y)}, ${z}`;
const formatReadout = (readout: string) => decodeHtmlEntities(readout);

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

interface SliderProps {
  format?: (value: number) => string;
  maxValue: number;
  minValue: number;
  step?: number;
  stepPixelSize?: number;
}

interface CoordinateSliderProps extends SliderProps {
  format?: (value: number) => string;
  onAdjust?: (adjust: number) => void;
  onChange: (value: number) => void;
  nudgeAmount?: number;
  stepAmount?: number;
  skipAmount?: number;
  value: number;
}

const CoordinateSlider = (props: CoordinateSliderProps) => {
  const {
    format,
    maxValue,
    minValue,
    onAdjust,
    onChange,
    nudgeAmount,
    skipAmount,
    stepAmount = 1,
    step,
    value,
    ...rest
  } = props;
  const handleAdjust = (adjust: number) => {
    if (onAdjust) {
      onAdjust(adjust);
      return;
    }
    onChange(clamp(value + adjust, minValue, maxValue));
  };
  return (
    <Stack inline width="100%">
      <Stack.Item>
        <Button icon="backward-fast" onClick={() => onChange(minValue)} />
        {!!skipAmount && <Button icon="backward-step" onClick={() => handleAdjust(-skipAmount)} />}
        <Button icon="backward" onClick={() => handleAdjust(-stepAmount)} />
        {!!nudgeAmount && (
          <Button onClick={() => handleAdjust(nudgeAmount)}>
            <Icon name="play" rotation={180} />
          </Button>
        )}
      </Stack.Item>
      <Stack.Item grow={1}>
        <Slider
          {...rest}
          format={format}
          value={value}
          minValue={minValue}
          maxValue={maxValue}
          step={step}
          onChange={(_e, newValue) => onChange(newValue)}
        />
      </Stack.Item>
      <Stack.Item>
        {!!nudgeAmount && <Button icon="play" onClick={() => handleAdjust(nudgeAmount)} />}
        <Button icon="forward" onClick={() => handleAdjust(stepAmount)} />
        {!!skipAmount && <Button icon="forward-step" onClick={() => handleAdjust(skipAmount)} />}
        <Button icon="fast-forward" onClick={() => onChange(maxValue)} />
      </Stack.Item>
    </Stack>
  );
};

const CoordinatesSection = (_props, context) => {
  const { act, data } = useBackend<TeleConsoleData>(context);
  const { xTarget, yTarget, zTarget } = data;
  return (
    <Section title="Target">
      <LabeledList>
        <LabeledList.Item label="X">
          <CoordinateSlider
            format={formatDecimal}
            maxValue={500}
            minValue={0}
            nudgeAmount={0.25}
            skipAmount={10}
            stepAmount={1}
            step={0.25}
            onChange={(value) => act('setX', { value })}
            value={xTarget}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Y">
          <CoordinateSlider
            format={formatDecimal}
            maxValue={500}
            minValue={0}
            nudgeAmount={0.25}
            skipAmount={10}
            stepAmount={1}
            step={0.25}
            onChange={(value) => act('setY', { value })}
            value={yTarget}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Z">
          <CoordinateSlider
            maxValue={14}
            minValue={0}
            onChange={(value) => act('setZ', { value })}
            stepPixelSize={10}
            value={zTarget}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
