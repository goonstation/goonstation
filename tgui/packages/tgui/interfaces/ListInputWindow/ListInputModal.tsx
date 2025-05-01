/**
 * @file
 * @copyright 2024
 * @author jlsnow301 (https://github.com/jlsnow301) and pali (https://github.com/pali6)
 * @license ISC
 */

import { useState } from 'react';
import { Autofocus, Button, Input, Section, Stack } from 'tgui-core/components';

import {
  KEY_A,
  KEY_DOWN,
  KEY_END,
  KEY_ENTER,
  KEY_ESCAPE,
  KEY_F,
  KEY_HOME,
  KEY_PAGEDOWN,
  KEY_PAGEUP,
  KEY_TAB,
  KEY_UP,
  KEY_Z,
} from '../../../common/keycodes';
import { useBackend } from '../../backend';
import { InputButtons } from '../common/InputButtons';

type ListInputModalProps = {
  items: string[];
  default_item: string;
  message: string;
  on_selected: (entry: string) => void;
  on_cancel: () => void;
  start_with_search: boolean;
  capitalize: boolean;
};

export const ListInputModal = (props: ListInputModalProps) => {
  const {
    items = [],
    default_item,
    message,
    on_selected,
    on_cancel,
    start_with_search,
    capitalize,
  } = props;

  const [selected, setSelected] = useState(items.indexOf(default_item));
  // |goonstation-change| start_with_search option
  const [searchBarVisible, setSearchBarVisible] = useState(start_with_search);
  const [searchQuery, setSearchQuery] = useState('');

  const getSearchBar = () => {
    if (!searchBarVisible) {
      return undefined;
    }
    return document
      .getElementById('search_bar')
      ?.getElementsByTagName('input')[0];
  };

  // User presses up or down on keyboard
  // Simulates clicking an item
  const onArrowKey = (key: number) => {
    const len = filteredItems.length - 1;
    let direction = -1;
    switch (key) {
      case KEY_UP:
        direction = -1;
        break;
      case KEY_DOWN:
        direction = 1;
        break;
      case KEY_PAGEUP:
        direction = -10;
        break;
      case KEY_PAGEDOWN:
        direction = 10;
        break;
    }
    let newSelected = selected + direction;
    if (newSelected < 0 && Math.abs(direction) === 1) newSelected = len;
    if (newSelected > len && Math.abs(direction) === 1) newSelected = 0;
    if (newSelected < 0) newSelected = 0;
    if (newSelected > len) newSelected = len;
    setSelected(newSelected);
    document!.getElementById(newSelected.toString())?.focus();
  };
  // User selects an item with mouse
  const onClick = (index: number) => {
    if (index === selected) {
      return;
    }
    setSelected(index);
  };
  // User presses a letter key and searchbar is visible
  // |goonstation-change| send any text input to the search bar
  const onFocusSearch = (letter) => {
    let searchBarInput = getSearchBar();
    if (!searchBarInput) {
      return;
    }
    searchBarInput.focus();
    searchBarInput.value += letter;
    onSearch(searchBarInput.value);
  };
  // User presses a letter key with no searchbar visible
  // |goonstation-change| improve the way items are selected after key presses
  const onLetterSearch = (key: number) => {
    const keyChar = String.fromCharCode(key);
    let foundIndex = items.findIndex((item, index) => {
      return (
        item?.toLowerCase().startsWith(keyChar?.toLowerCase()) &&
        index > selected
      );
    });
    if (foundIndex === -1) {
      foundIndex = items.findIndex((item, index) => {
        return (
          item?.toLowerCase().startsWith(keyChar?.toLowerCase()) &&
          index <= selected
        );
      });
    }
    if (foundIndex !== -1) {
      setSelected(foundIndex);
      document!.getElementById(foundIndex.toString())?.focus();
    }
  };
  // User types into search bar
  // |goonstation-change| Only change selection when necessary
  const onSearch = (query: string) => {
    if (query === searchQuery) {
      return;
    }
    let currentSelectedText = filteredItems[selected];
    let newDisplayed = items.filter((val) =>
      val.toLowerCase().includes(query.toLowerCase()),
    );
    let newSelected = newDisplayed.indexOf(currentSelectedText);
    if (newSelected === -1 && newDisplayed.length > 0) {
      setSelected(0);
      document!.getElementById('0')?.scrollIntoView();
    } else if (newDisplayed.length !== 0) {
      setSelected(newSelected);
      document!.getElementById(newSelected.toString())?.scrollIntoView();
    }
    setSearchQuery(query);
  };
  // User presses the search button
  const onSearchBarToggle = () => {
    setSearchBarVisible(!searchBarVisible);
    setSearchQuery('');
  };
  const filteredItems = items.filter((item) =>
    item?.toLowerCase().includes(searchQuery.toLowerCase()),
  );
  // Grabs the cursor when no search bar is visible.
  if (!searchBarVisible) {
    setTimeout(() => document!.getElementById(selected.toString())?.focus(), 1);
  }

  return (
    <Section
      onKeyDown={(event) => {
        const keyCode = window.event ? event.which : event.keyCode;
        const searchBarInput = getSearchBar();
        const searchBarFocused = document.activeElement === searchBarInput;
        const len = filteredItems.length - 1;

        switch (keyCode) {
          // |goonstation-change| Page Up/Down support
          case KEY_DOWN:
          case KEY_UP:
          case KEY_PAGEUP:
          case KEY_PAGEDOWN:
            event.preventDefault();
            onArrowKey(keyCode);
            break;
          // |goonstation-change| Ctrl+F support
          case KEY_F:
            if (event.ctrlKey) {
              setSearchBarVisible(!searchBarVisible);
              setSearchQuery('');
              event.preventDefault();
              if (searchBarVisible && searchBarInput) {
                searchBarInput.focus();
              }
              return;
            }
            break;
          case KEY_ENTER:
            event.preventDefault();
            on_selected(filteredItems[selected]);
            break;
          case KEY_ESCAPE:
            event.preventDefault();
            on_cancel();
            break;
          // |goonstation-change| Home support
          case KEY_HOME:
            setSelected(0);
            document!.getElementById('0')?.focus();
            event.preventDefault();
            break;
          // |goonstation-change| End support
          case KEY_END:
            setSelected(len);
            document!.getElementById(len.toString())?.focus();
            event.preventDefault();
            break;
          // |goonstation-change| Tab support
          case KEY_TAB:
            if (searchBarVisible) {
              let selectedButtonElement = document.getElementById(
                selected.toString(),
              );
              if (searchBarFocused && selectedButtonElement) {
                selectedButtonElement.focus();
              } else if (searchBarInput && !searchBarFocused) {
                searchBarInput.focus();
              }
              event.preventDefault();
            }
            break;
        }

        if (!searchBarVisible && KEY_A <= keyCode && keyCode <= KEY_Z) {
          event.preventDefault();
          onLetterSearch(keyCode);
        }
      }}
      buttons={
        <Button
          compact
          icon={searchBarVisible ? 'search' : 'font'}
          selected
          tooltip={
            searchBarVisible
              ? 'Search Mode. Type to search or use arrow keys to select manually.'
              : 'Hotkey Mode. Type a letter to jump to the first match. Enter to select.'
          }
          tooltipPosition="left"
          onClick={() => onSearchBarToggle()}
        />
      }
      className="ListInput__Section"
      fill
      title={message}
    >
      <Stack fill vertical>
        <Stack.Item grow>
          <ListDisplay
            filteredItems={filteredItems}
            onClick={onClick}
            onFocusSearch={onFocusSearch}
            searchBarVisible={searchBarVisible}
            selected={selected}
            capitalize={capitalize}
          />
        </Stack.Item>
        {searchBarVisible !== false && (
          <SearchBar
            filteredItems={filteredItems}
            onSearch={onSearch}
            searchQuery={searchQuery}
            selected={selected}
          />
        )}
        <Stack.Item>
          <InputButtons
            input={filteredItems[selected]}
            on_submit={() => on_selected(filteredItems[selected])}
            on_cancel={on_cancel}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

/**
 * Displays the list of selectable items.
 * If a search query is provided, filters the items.
 */
const ListDisplay = (props) => {
  const { act } = useBackend();
  const {
    filteredItems,
    onClick,
    onFocusSearch,
    searchBarVisible,
    selected,
    capitalize,
  } = props;

  return (
    <Section fill scrollable>
      <Autofocus />
      {filteredItems.map((item, index) => {
        return (
          <Button
            color="transparent"
            fluid
            id={index}
            key={index}
            className="search-item"
            onClick={() => onClick(index)}
            onDoubleClick={(event) => {
              event.preventDefault();
              act('submit', { entry: filteredItems[selected] });
            }}
            onKeyDown={(event) => {
              const keyCode = window.event ? event.which : event.keyCode;
              if (searchBarVisible && event.key.length === 1) {
                let char = String.fromCharCode(keyCode);
                if (!event.shiftKey) {
                  char = char.toLowerCase();
                }
                event.preventDefault();
                event.stopPropagation();
                onFocusSearch(char);
              }
            }}
            selected={index === selected}
            style={{
              animation: 'none',
              transition: 'none',
            }}
          >
            {
              // |goonstation-change| capitalize option
              capitalize ? item.replace(/^\w/, (c) => c.toUpperCase()) : item
            }
          </Button>
        );
      })}
    </Section>
  );
};

/**
 * Renders a search bar input.
 * Closing the bar defaults input to an empty string.
 */
const SearchBar = (props) => {
  const { act } = useBackend();
  const { filteredItems, onSearch, searchQuery, selected } = props;

  return (
    <Input
      autoFocus
      autoSelect
      fluid
      id="search_bar"
      onEnter={(event) => {
        act('submit', { entry: filteredItems[selected] });
      }}
      onChange={(value) => onSearch(value)}
      placeholder="Search..."
      value={searchQuery}
    />
  );
};
