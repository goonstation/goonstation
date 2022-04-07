/**
 * @file
 * @copyright 2020 watermelon914 (https://github.com/watermelon914)
 * @license MIT
 */

import { clamp01 } from 'common/math';
import { KEY_UP, KEY_DOWN, KEY_PAGEDOWN, KEY_END, KEY_HOME, KEY_PAGEUP, KEY_ESCAPE, KEY_ENTER, KEY_TAB } from 'common/keycodes';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Input, Stack } from '../components';
import { Window } from '../layouts';

let nextScrollTime = 0;

const nextTick
= typeof Promise !== 'undefined'
  ? Promise.resolve().then.bind(Promise.resolve())
  : function (a) {
    window.setTimeout(a, 0);
  };

export const ListInput = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    title,
    message,
    buttons,
    timeout,
  } = data;

  // Search
  const [showSearchBar, setShowSearchBar] = useLocalState(
    context, 'search_bar', false);
  const [displayedArray, setDisplayedArray] = useLocalState(
    context, 'displayed_array', buttons);

  // KeyPress
  const [searchArray, setSearchArray] = useLocalState(
    context, 'search_array', []);
  const [searchIndex, setSearchIndex] = useLocalState(
    context, 'search_index', 0);
  const [lastCharCode, setLastCharCode] = useLocalState(
    context, 'last_char_code', null);

  // Selected Button
  const [selectedButton, setSelectedButton] = useLocalState(
    context, 'selected_button', buttons[0]);

  const handleKeyDown = e => {
    let searchBarInput = showSearchBar ? document.getElementById("search_bar").getElementsByTagName('input')[0] : null;
    let searchBarFocused = document.activeElement === searchBarInput;
    if (!searchBarFocused) {
      e.preventDefault();
    }

    if (!searchBarFocused && e.keyCode === KEY_END) {
      if (!displayedArray.length) {
        return;
      }
      const button = displayedArray[buttons.length - 1];
      setSelectedButton(button);
      setLastCharCode(null);
      document.getElementById(button).focus();
    }
    else if (!searchBarFocused && e.keyCode === KEY_HOME) {
      if (!displayedArray.length) {
        return;
      }
      const button = displayedArray[0];
      setSelectedButton(button);
      setLastCharCode(null);
      document.getElementById(button).focus();
    }
    else if (e.keyCode === KEY_ESCAPE) {
      act("cancel");
    }
    else if (e.keyCode === KEY_ENTER) {
      act("choose", { choice: selectedButton });
    }
    else if (e.keyCode === KEY_TAB) {
      let selectedButtonElement = document.getElementById(selectedButton);
      if (searchBarFocused && selectedButtonElement) {
        selectedButtonElement.focus();
      }
      else if (searchBarInput && !searchBarFocused) {
        searchBarInput.focus();
      }
      e.preventDefault();
    }
    else if (e.keyCode === KEY_UP || e.keyCode === KEY_DOWN || e.keyCode === KEY_PAGEDOWN || e.keyCode === KEY_PAGEUP) {
      if (nextScrollTime > performance.now() || !displayedArray.length) {
        return;
      }
      nextScrollTime = performance.now() + 50;

      let direction;
      switch (e.keyCode) {
        case KEY_UP: direction = -1; break;
        case KEY_DOWN: direction = 1; break;
        case KEY_PAGEUP: direction = -10; break;
        case KEY_PAGEDOWN: direction = 10; break;
      }

      let index = 0;
      for (index; index < displayedArray.length; index++) {
        if (displayedArray[index] === selectedButton) break;
      }
      index += direction;
      if (index < 0 && Math.abs(direction) === 1) index = displayedArray.length - 1;
      else if (index >= displayedArray.length && Math.abs(direction) === 1) index = 0;
      else if (index < 0) index = 0;
      else if (index >= displayedArray.length) index = displayedArray.length - 1;
      const button = displayedArray[index];
      setSelectedButton(button);
      setLastCharCode(null);
      document.getElementById(button).focus();
    }

    const charCode = String.fromCharCode(e.keyCode).toLowerCase();
    if (!charCode) return;

    if (charCode === "f" && e.ctrlKey) {
      if (!showSearchBar) {
        nextTick(() => document.getElementById("search_bar").getElementsByTagName('input')[0].focus());
      }
      else {
        document.getElementById(selectedButton)?.focus();
      }
      setShowSearchBar(!showSearchBar);
      e.preventDefault();
      return;
    }

    if (searchBarFocused) {
      return;
    }

    if (nextScrollTime > performance.now() || !displayedArray.length) {
      return;
    }
    nextScrollTime = performance.now() + 50;

    let foundValue;
    if (charCode === lastCharCode && searchArray.length > 0) {
      const nextIndex = searchIndex + 1;

      if (nextIndex < searchArray.length) {
        foundValue = searchArray[nextIndex];
        setSearchIndex(nextIndex);
      }
      else {
        foundValue = searchArray[0];
        setSearchIndex(0);
      }
    }
    else {
      const resultArray = displayedArray.filter(value =>
        value.substring(0, 1).toLowerCase() === charCode
      );

      if (resultArray.length > 0) {
        setSearchArray(resultArray);
        setSearchIndex(0);
        foundValue = resultArray[0];
      }
    }

    if (foundValue) {
      setLastCharCode(charCode);
      setSelectedButton(foundValue);
      document.getElementById(foundValue).focus();
    }
  };

  return (
    <Window
      title={title}
      width={325}
      height={325}>
      {timeout !== undefined && <Loader value={timeout} />}
      <Window.Content
        onkeydown={handleKeyDown}>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              className="ListInput__Section"
              title={message}
              tabIndex={0}
              buttons={(
                <Button
                  compact
                  icon="search"
                  color="transparent"
                  selected={showSearchBar}
                  tooltip="Search Bar"
                  tooltipPosition="left"
                  onClick={() => {
                    if (!showSearchBar) {
                      nextTick(() => document.getElementById("search_bar").getElementsByTagName('input')[0].focus());
                    }
                    else {
                      document.getElementById(selectedButton)?.focus();
                    }
                    setShowSearchBar(!showSearchBar);
                    setDisplayedArray(buttons);
                  }}
                />
              )}>
              {displayedArray.map(button => (
                <Button
                  key={button}
                  fluid
                  color="transparent"
                  id={button}
                  selected={selectedButton === button}
                  onComponentDidMount={node => {
                    let searchBarInput = showSearchBar ? document.getElementById("search_bar").getElementsByTagName('input')[0] : null;
                    let searchBarFocused = document.activeElement === searchBarInput;
                    if (selectedButton === button && !searchBarFocused) {
                      node.focus();
                    }
                  }}
                  onClick={() => {
                    if (selectedButton === button) {
                      act('choose', { choice: button });
                    }
                    else {
                      setSelectedButton(button);
                    }
                    setLastCharCode(null);
                  }}>
                  {button}
                </Button>
              ))}
            </Section>
          </Stack.Item>
          {showSearchBar && (
            <Stack.Item>
              <Input
                fluid
                id="search_bar"
                onInput={(e, value) => {
                  let newDisplayed = buttons.filter(val => (
                    val.toLowerCase().search(value.toLowerCase()) !== -1
                  ));
                  setDisplayedArray(newDisplayed);
                  if (!newDisplayed.includes(selectedButton) && newDisplayed.length > 0) {
                    setSelectedButton(newDisplayed[0]);
                  }
                }}
              />
            </Stack.Item>
          )}
          <Stack.Item>
            <Stack textAlign="center">
              <Stack.Item grow basis={0}>
                <Button
                  fluid
                  color="good"
                  lineHeight={2}
                  content="Confirm"
                  disabled={selectedButton === null}
                  onClick={() => act("choose", { choice: selectedButton })}
                />
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <Button
                  fluid
                  color="bad"
                  lineHeight={2}
                  content="Cancel"
                  onClick={() => act("cancel")}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const Loader = props => {
  const { value } = props;
  return (
    <div className="ListInput__Loader">
      <Box
        className="ListInput__LoaderProgress"
        style={{
          width: clamp01(value) * 100 + '%',
        }} />
    </div>
  );
};
