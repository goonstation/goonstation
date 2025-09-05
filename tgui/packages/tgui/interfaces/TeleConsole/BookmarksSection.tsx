/**
 * @file
 * @copyright 2023
 * @author Original Valtsu0 (https://github.com/Valtsu0)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { decodeHtmlEntities } from 'common/string';
import { useState } from 'react';
import { Button, Input, LabeledList, Section } from 'tgui-core/components';

import { TeleConsoleData } from './types';
import { formatCoordinates } from './util';

type BookmarksSectionProps = Pick<TeleConsoleData, 'bookmarks'> & {
  maxBookmarks: number;
  onAddBookmark: (name: string) => void;
  onDeleteBookmark: (ref: string) => void;
  onRestoreBookmark: (ref: string) => void;
  targetCoords: [number, number, number];
};

export const BookmarksSection = (props: BookmarksSectionProps) => {
  const {
    bookmarks,
    maxBookmarks,
    onAddBookmark,
    onDeleteBookmark,
    onRestoreBookmark,
    targetCoords,
  } = props;
  const [newBookmarkName, setNewBookmarkName] = useState('');
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
              key={bookmark.nameRef}
              label={formatCoordinates(bookmark.x, bookmark.y, bookmark.z)}
              buttons={
                <Button
                  icon="trash"
                  color="red"
                  onClick={() => onDeleteBookmark(bookmark.nameRef)}
                />
              }
            >
              <Button
                icon="bookmark"
                onClick={() => onRestoreBookmark(bookmark.nameRef)}
              >
                {decodeHtmlEntities(bookmark.name)}
              </Button>
            </LabeledList.Item>
          );
        })}
        {!!(bookmarks.length < maxBookmarks) && (
          <LabeledList.Item
            key="new"
            label={formatCoordinates(...targetCoords)}
            buttons={
              <Button
                icon="plus"
                onClick={() => handleAddBookmark(newBookmarkName)}
              />
            }
          >
            <Input
              width="100%"
              value={newBookmarkName}
              onChange={(value: string) => setNewBookmarkName(value)}
              placeholder="New bookmark"
              onEnter={(value: string) => handleAddBookmark(value)}
              maxLength={32}
            />
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};
