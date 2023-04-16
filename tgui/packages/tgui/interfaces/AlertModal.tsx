/**
 * @file
 * @copyright 2020 bobbahbrown (https://github.com/bobbahbrown)
 * @copyright 2022 jlsnow301 (https://github.com/jlsnow301)
 * @license MIT
 */

import { Loader } from './common/Loader';
import { useBackend, useLocalState } from '../backend';
import { KEY_ENTER, KEY_ESCAPE, KEY_LEFT, KEY_RIGHT, KEY_SPACE, KEY_TAB } from '../../common/keycodes';
import { Autofocus, Box, Button, Flex, Section, Stack } from '../components';
import { Window } from '../layouts';

type AlertModalData = {
  autofocus: boolean;
  items: string[];
  message: string;
  timeout: number;
  title: string;
};

const KEY_DECREMENT = -1;
const KEY_INCREMENT = 1;

export const AlertModal = (props, context) => {
  const { act, data } = useBackend<AlertModalData>(context);
  const {
    autofocus,
    items = [],
    message = '',
    timeout,
    title,
  } = data;
  const [selected, setSelected] = useLocalState<number>(context, 'selected', 0);
  // Dynamically sets window dimensions
  const windowHeight
     = 115
     + (message.length > 30 ? Math.ceil(message.length / 4) : 0);
  const windowWidth = 325 + (items.length > 2 ? 55 : 0);
  const onKey = (direction: number) => {
    if (selected === 0 && direction === KEY_DECREMENT) {
      setSelected(items.length - 1);
    } else if (selected === items.length - 1 && direction === KEY_INCREMENT) {
      setSelected(0);
    } else {
      setSelected(selected + direction);
    }
  };

  return (
    <Window height={windowHeight} title={title} width={windowWidth}>
      {!!timeout && <Loader value={timeout} />}
      <Window.Content
        onKeyDown={(e) => {
          const keyCode = window.event ? e.which : e.keyCode;
          /**
            * Simulate a click when pressing space or enter,
            * allow keyboard navigation, override tab behavior
            */
          if (keyCode === KEY_SPACE || keyCode === KEY_ENTER) {
            act('choose', { choice: items[selected] });
          } else if (keyCode === KEY_ESCAPE) {
            act('cancel');
          } else if (keyCode === KEY_LEFT) {
            e.preventDefault();
            onKey(KEY_DECREMENT);
          } else if (keyCode === KEY_TAB || keyCode === KEY_RIGHT) {
            e.preventDefault();
            onKey(KEY_INCREMENT);
          }
        }}>
        <Section fill>
          <Stack fill vertical>
            <Stack.Item grow m={1}>
              <Box color="label" overflow="hidden">
                {message}
              </Box>
            </Stack.Item>
            <Stack.Item>
              {!!autofocus && <Autofocus />}
              <ButtonDisplay selected={selected} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

/**
  * Displays a list of items ordered by user prefs.
  * Technically this handles more than 2 items, but you
  * should just be using a list input in that case.
  */
const ButtonDisplay = (props, context) => {
  const { data } = useBackend<AlertModalData>(context);
  const { items = [] } = data;
  const { selected } = props;

  return (
    <Flex
      align="center"
      direction={'row'}
      fill
      justify="space-around"
      wrap>
      {items?.map((button, index) =>
        (
          <Flex.Item key={index}>
            <AlertButton
              button={button}
              id={index.toString()}
              selected={selected === index}
            />
          </Flex.Item>
        )
      )}
    </Flex>
  );
};

/**
  * Displays a button with variable sizing.
  */
const AlertButton = (props, context) => {
  const { act, data } = useBackend<AlertModalData>(context);
  const { button, selected } = props;
  const buttonWidth = button.length > 7 ? button.length : 7;

  return (
    <Button
      onClick={() => act('choose', { choice: button })}
      m={0.5}
      pl={2}
      pr={2}
      pt={0}
      selected={selected}
      textAlign="center"
      width={buttonWidth}>
      {button}
    </Button>
  );
};
