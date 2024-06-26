/**
 * @file
 * @copyright 2022
 * @author jlsnow301 (https://github.com/jlsnow301) and pali (https://github.com/pali6)
 * @license ISC
 */

import { Loader } from './common/Loader';
import { InputButtons } from './common/InputButtons';
import { Button, Input, Section, Stack } from '../components';
import { KEY_A, KEY_DOWN, KEY_END, KEY_ENTER, KEY_ESCAPE, KEY_HOME, KEY_PAGEDOWN, KEY_PAGEUP, KEY_TAB, KEY_UP, KEY_Z } from 'common/keycodes';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';

const nextTick
= typeof Promise !== 'undefined'
  ? Promise.resolve().then.bind(Promise.resolve())
  : function (a) {
    window.setTimeout(a, 0);
  };

 type ListInputData = {
   items: string[];
   message: string;
   init_value: string;
   timeout: number;
   title: string;
   start_with_search: number;
   capitalize: number;
   theme: string;
 };



/**
* Uses canvas.measureText to compute and return the width of the given text of given font in pixels.
*
* @param {String} text The text to be rendered.
* @param {String} font The css font descriptor that text is to be rendered with (e.g. "bold 14px verdana").
*
* @see https://stackoverflow.com/questions/118241/calculate-text-width-with-javascript/21015393#21015393
*/
const getTextWidth = (text, font, defaultWidth: number) => {
  // re-use canvas object for better performance
  const canvas = textWidthCanvas || (textWidthCanvas = document.createElement("canvas"));
  const context = canvas.getContext("2d");
  if (!context) {
    return defaultWidth;
  }
  context.font = font;
  const metrics = context.measureText(text);
  return metrics.width;
};
let textWidthCanvas: HTMLCanvasElement | null = null;

const getCssStyle = (element, prop) => {
  return window.getComputedStyle(element, null).getPropertyValue(prop);
};

const getCanvasFont = (el = document.body) => {
  const fontWeight = getCssStyle(el, 'font-weight') || 'normal';
  const fontSize = getCssStyle(el, 'font-size') || '16px';
  const fontFamily = getCssStyle(el, 'font-family') || 'Times New Roman';

  return `${fontWeight} ${fontSize} ${fontFamily}`;
};

export const ListInputModal = (_, context) => {
  const { act, data } = useBackend<ListInputData>(context);
  const { items = [], message, init_value, timeout, title, start_with_search, capitalize, theme } = data;
  const [selected, setSelected] = useLocalState<number>(
    context,
    'selected',
    items.indexOf(init_value)
  );
  const [searchBarVisible, setSearchBarVisible] = useLocalState<boolean>(
    context,
    'searchBarVisible',
    start_with_search === 1
  );
  const [searchQuery, setSearchQuery] = useLocalState<string>(
    context,
    'searchQuery',
    ''
  );
  const [windowWidth, setWindowWidth] = useLocalState<number | null>(
    context,
    'windowWidth',
    null
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
  const onFocusSearch = (letter) => {
    let searchBarInput = searchBarVisible ? document.getElementById("search_bar")?.getElementsByTagName('input')[0] : null;
    if (!searchBarInput) {
      return;
    }
    searchBarInput.focus();
    searchBarInput.value += letter;
    onSearch(searchBarInput.value);
  };
  // User presses a letter key with no searchbar visible
  const onLetterSearch = (key: number) => {
    const keyChar = String.fromCharCode(key);
    let foundIndex = items.findIndex((item, index) => {
      return item?.toLowerCase().startsWith(keyChar?.toLowerCase()) && index > selected;
    });
    if (foundIndex === -1) {
      foundIndex = items.findIndex((item, index) => {
        return item?.toLowerCase().startsWith(keyChar?.toLowerCase()) && index <= selected;
      });
    }
    if (foundIndex !== -1) {
      setSelected(foundIndex);
      document!.getElementById(foundIndex.toString())?.focus();
    }
  };
  // User types into search bar
  const onSearch = (query: string) => {
    if (query === searchQuery) {
      return;
    }
    let currentSelectedText = filteredItems[selected];
    let newDisplayed = items.filter(val => (
      val.toLowerCase().includes(query.toLowerCase())
    ));
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
    item?.toLowerCase().includes(searchQuery.toLowerCase())
  );
  // Dynamically changes the window height based on the message.
  const windowHeight
     = 325 + Math.ceil(message?.length / 3);
  // Grabs the cursor when no search bar is visible.
  if (!searchBarVisible) {
    setTimeout(() => document!.getElementById(selected.toString())?.focus(), 1);
  }

  const handleKey = (event) => {
    let searchBarInput = searchBarVisible ? document.getElementById("search_bar")?.getElementsByTagName('input')[0] : null;
    let searchBarFocused = document.activeElement === searchBarInput;
    const len = filteredItems.length - 1;
    const keyCode = window.event ? event.which : event.keyCode;
    const charCode = String.fromCharCode(event.keyCode).toLowerCase();
    if (keyCode === KEY_DOWN || keyCode === KEY_UP || keyCode === KEY_PAGEUP || keyCode === KEY_PAGEDOWN) {
      event.preventDefault();
      onArrowKey(keyCode);
    }
    else if (charCode === "f" && event.ctrlKey) {
      if (!searchBarVisible) {
        nextTick(() => document.getElementById("search_bar")?.getElementsByTagName('input')[0].focus());
      }
      setSearchBarVisible(!searchBarVisible);
      setSearchQuery('');
      event.preventDefault();
      return;
    }
    else if (keyCode === KEY_ENTER) {
      event.preventDefault();
      act('submit', { entry: filteredItems[selected] });
    }
    else if (keyCode === KEY_ESCAPE) {
      event.preventDefault();
      act('cancel');
    }
    else if (keyCode === KEY_END) {
      setSelected(len);
      document!.getElementById(len.toString())?.focus();
      event.preventDefault();
    }
    else if (keyCode === KEY_HOME) {
      setSelected(0);
      document!.getElementById('0')?.focus();
      event.preventDefault();
    }
    else if (keyCode === KEY_TAB && searchBarVisible) {
      let selectedButtonElement = document.getElementById(selected.toString());
      if (searchBarFocused && selectedButtonElement) {
        selectedButtonElement.focus();
      }
      else if (searchBarInput && !searchBarFocused) {
        searchBarInput.focus();
      }
      event.preventDefault();
    }
    else if (!searchBarVisible && keyCode >= KEY_A && keyCode <= KEY_Z && !event.ctrlKey) {
      event.preventDefault();
      event.stopPropagation();
      onLetterSearch(keyCode);
    }
  };

  let actualWindowWidth = windowWidth;
  if (windowWidth === null) {
    let maxWidth = 325;
    const font = getCanvasFont();
    for (const item of items) {
      maxWidth = Math.max(maxWidth, getTextWidth(item, font, maxWidth));
    }
    // No clue why the nextTick is necessary but it seems like if you do it directly then there's about
    // 50% chance something in Inferno will race condition and crash. Pls help.
    nextTick(() => setWindowWidth(maxWidth));
    actualWindowWidth = maxWidth;
  }

  return (
    <Window title={title} width={actualWindowWidth} height={windowHeight} theme={theme || 'nanotrasen'}>
      {timeout && <Loader value={timeout} />}
      <Window.Content
        onkeydown={handleKey}>
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
                capitalize={capitalize}
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
  const { filteredItems, onClick, onFocusSearch, searchBarVisible, selected, capitalize }
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
            onkeydown={(event) => {
              const keyCode = window.event ? event.which : event.keyCode;
              let char = String.fromCharCode(keyCode);
              if (!event.shiftKey) {
                char = char.toLowerCase();
              }
              if (searchBarVisible && event.key.length === 1) {
                event.preventDefault();
                event.stopPropagation();
                onFocusSearch(char);
              }
            }}
            selected={index === selected}
            style={{
              'animation': 'none',
              'transition': 'none',
            }}>
            {capitalize ? item.replace(/^\w/, (c) => c.toUpperCase()) : item}
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
      id="search_bar"
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
