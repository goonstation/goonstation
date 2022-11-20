/**
 * @file
 * @copyright 2022
 * @author jlsnow301 (https://github.com/jlsnow301) and pali (https://github.com/pali6)
 * @license ISC
 */

import { Loader } from './common/Loader';
import { InputButtons } from './common/InputButtons';
import { Button, Input, Section, Stack } from '../components';
import { KEY_A, KEY_DOWN, KEY_ESCAPE, KEY_ENTER, KEY_UP, KEY_Z, KEY_PAGEUP, KEY_PAGEDOWN, KEY_END, KEY_HOME } from 'common/keycodes';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';

 type ListInputData = {
   items: string[];
   message: string;
   init_value: string;
   timeout: number;
   title: string;
 };

export const ListInputModal = (_, context) => {
  const { act, data } = useBackend<ListInputData>(context);
  const { items = [], message, init_value, timeout, title } = data;
  const [selected, setSelected] = useLocalState<number>(
    context,
    'selected',
    items.indexOf(init_value)
  );
  const [searchBarVisible, setSearchBarVisible] = useLocalState<boolean>(
    context,
    'searchBarVisible',
    items.length > 9
  );
  const [searchQuery, setSearchQuery] = useLocalState<string>(
    context,
    'searchQuery',
    ''
  );
  // User presses up or down on keyboard
  // Simulates clicking an item
  const onArrowKey = (key: number) => {
    const len = filteredItems.length - 1;
    let direction = -1;
    switch (key) {
      case KEY_UP: direction = -1; break;
      case KEY_DOWN: direction = 1; break;
      case KEY_PAGEUP: direction = -10; break;
      case KEY_PAGEDOWN: direction = 10; break;
    }
    let newSelected = selected + direction;
    if (newSelected < 0 && Math.abs(direction) === 1) newSelected = len;
    if (newSelected > len && Math.abs(direction) === 1) newSelected = 0;
    if (newSelected < 0) newSelected = 0;
    if (newSelected > len) newSelected = len;
    setSelected(newSelected);
     document!.getElementById(newSelected.toString())?.scrollIntoView();
  };
  // User selects an item with mouse
  const onClick = (index: number) => {
    if (index === selected) {
      return;
    }
    setSelected(index);
  };
  // User presses a letter key and searchbar is visible
  const onFocusSearch = () => {
    setSearchBarVisible(false);
    setSearchBarVisible(true);
  };
  // User presses a letter key with no searchbar visible
  const onLetterSearch = (key: number) => {
    const keyChar = String.fromCharCode(key);
    const foundItem = items.find((item) => {
      return item?.toLowerCase().startsWith(keyChar?.toLowerCase());
    });
    if (foundItem) {
      const foundIndex = items.indexOf(foundItem);
      setSelected(foundIndex);
       document!.getElementById(foundIndex.toString())?.scrollIntoView();
    }
  };
  // User types into search bar
  const onSearch = (query: string) => {
    if (query === searchQuery) {
      return;
    }
    setSearchQuery(query);
    setSelected(0);
     document!.getElementById('0')?.scrollIntoView();
  };
  // User presses the search button
  const onSearchBarToggle = () => {
    setSearchBarVisible(!searchBarVisible);
    setSearchQuery('');
  };
  const filteredItems = items.filter((item) =>
    item?.toLowerCase().includes(searchQuery.toLowerCase())
  );
  // Dynamically changes the window height based on the message.
  const windowHeight
     = 325 + Math.ceil(message?.length / 3);
  // Grabs the cursor when no search bar is visible.
  if (!searchBarVisible) {
    setTimeout(() => document!.getElementById(selected.toString())?.focus(), 1);
  }

  return (
    <Window title={title} width={325} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content
        onKeyDown={(event) => {
          const len = filteredItems.length - 1;
          const keyCode = window.event ? event.which : event.keyCode;
          if (keyCode === KEY_DOWN || keyCode === KEY_UP || keyCode === KEY_PAGEUP || keyCode === KEY_PAGEDOWN) {
            event.preventDefault();
            onArrowKey(keyCode);
          }
          if (keyCode === KEY_ENTER) {
            event.preventDefault();
            act('submit', { entry: filteredItems[selected] });
          }
          if (!searchBarVisible && keyCode >= KEY_A && keyCode <= KEY_Z) {
            event.preventDefault();
            onLetterSearch(keyCode);
          }
          if (keyCode === KEY_ESCAPE) {
            event.preventDefault();
            act('cancel');
          }
          if (keyCode === KEY_END) {
            setSelected(len);
             document!.getElementById(len.toString())?.scrollIntoView();
             event.preventDefault();
          }
          if (keyCode === KEY_HOME) {
            setSelected(0);
             document!.getElementById('0')?.scrollIntoView();
             event.preventDefault();
          }
        }}>
        <Section
          buttons={
            <Button
              compact
              icon={searchBarVisible ? "search" : "font"}
              selected
              tooltip={searchBarVisible
                ? "Search Mode. Type to search or use arrow keys to select manually."
                : "Hotkey Mode. Type a letter to jump to the first match. Enter to select."}
              tooltipPosition="left"
              onClick={() => onSearchBarToggle()}
            />

          }
          className="ListInput__Section"
          fill
          title={message}>
          <Stack fill vertical>
            <Stack.Item grow>
              <ListDisplay
                filteredItems={filteredItems}
                onClick={onClick}
                onFocusSearch={onFocusSearch}
                searchBarVisible={searchBarVisible}
                selected={selected}
              />
            </Stack.Item>
            {searchBarVisible && (
              <SearchBar
                filteredItems={filteredItems}
                onSearch={onSearch}
                searchQuery={searchQuery}
                selected={selected}
              />
            )}
            <Stack.Item>
              <InputButtons input={filteredItems[selected]} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

/**
  * Displays the list of selectable items.
  * If a search query is provided, filters the items.
  */
const ListDisplay = (props, context) => {
  const { act } = useBackend<ListInputData>(context);
  const { filteredItems, onClick, onFocusSearch, searchBarVisible, selected }
     = props;

  return (
    <Section fill scrollable tabIndex={0}>
      {filteredItems.map((item, index) => {
        return (
          <Button
            color="transparent"
            fluid
            id={index}
            key={index}
            onClick={() => onClick(index)}
            onDblClick={(event) => {
              event.preventDefault();
              act('submit', { entry: filteredItems[selected] });
            }}
            onKeyDown={(event) => {
              const keyCode = window.event ? event.which : event.keyCode;
              if (searchBarVisible && keyCode >= KEY_A && keyCode <= KEY_Z) {
                event.preventDefault();
                onFocusSearch();
              }
            }}
            selected={index === selected}
            style={{
              'animation': 'none',
              'transition': 'none',
            }}>
            {item.replace(/^\w/, (c) => c.toUpperCase())}
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
const SearchBar = (props, context) => {
  const { act } = useBackend<ListInputData>(context);
  const { filteredItems, onSearch, searchQuery, selected } = props;

  return (
    <Input
      autoFocus
      autoSelect
      fluid
      onEnter={(event) => {
        event.preventDefault();
        act('submit', { entry: filteredItems[selected] });
      }}
      onInput={(_, value) => onSearch(value)}
      placeholder="Search..."
      value={searchQuery}
    />
  );
};
