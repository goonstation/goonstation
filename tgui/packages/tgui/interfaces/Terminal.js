import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Box, Button, Flex, Input, Section, Stack, Tooltip } from '../components';

export const Terminal = (_props, context) => {
  const { act, data } = useBackend(context);
  const peripherals = data.peripherals || [];
  const [textInput, setTextInput] = useLocalState(context, 'textInput', "");
  const [textInputHistory, setTextInputHistory] = useLocalState(context, 'textInputHistory', []);
  const [textInputHistoryIndex, setTextInputHistoryIndex] = useLocalState(context, 'textInputHistoryIndex', 0);
  const {
    displayHTML,
    TermActive,
    windowName,
    fontColor,
    bgColor,
    doScrollBottom,
  } = data;

  let navigateHistory = function (direction, DOMInput) {
    let newIndex = textInputHistoryIndex + direction;
    let hasMoreHistory = false;
    if (direction > 0 && newIndex < textInputHistory.length) {
      hasMoreHistory = true;
    } else if (direction < 0 && newIndex >= 0) {
      hasMoreHistory = true;
    }
    if (hasMoreHistory) {
      setTextInput(textInputHistory[newIndex]);
      // setTextInput *should* have been good enough but sometimes, after editing the input, it fails to update,
      // so let's update the dom input directly just to be sure
      DOMInput.value = textInputHistory[newIndex];
      setTextInputHistoryIndex(newIndex);
    } else if (direction > 0) {
      // The last down arrow should clear the text field
      setTextInput("");
      DOMInput.value = "";
      setTextInputHistoryIndex(textInputHistory.length);
    }
  };

  let appendHistory = function (newText) {
    if (textInputHistory[textInputHistory.length - 1] === newText) {
      return;
    }
    textInputHistory.push(newText);
    setTextInputHistory(textInputHistory);
    setTextInputHistoryIndex(textInputHistoryIndex + 1);
  };

  let handleScrollBottom = function () {
    // There might be a better way than this setTimeout like fashion to run our js scroll code at the right time
    // but I'm not familiar enough with Inferno hooks to find it
    window.requestAnimationFrame(() => {
      if (!doScrollBottom) {
        return;
      }
      let terminalOutputScroll = document.querySelector('#terminalOutput .Section__content');
      if (!terminalOutputScroll) {
        return;
      }
      terminalOutputScroll.scrollTop = terminalOutputScroll.scrollHeight;
    });
  };

  return (
    <Window
      theme="retro-dark"
      title={windowName}
      fontFamily="Consolas"
      width="380"
      height="350">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Section backgroundColor={bgColor} scrollable fill id="terminalOutput">
              <Box
                fontFamily="Consolas"
                fill
                color={fontColor}
                dangerouslySetInnerHTML={{ __html: displayHTML }}
              />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section fitted>
              <Flex>
                <Flex.Item grow>
                  <Input
                    as="span"
                    placeholder="Type Here"
                    selfClear
                    value={textInput}
                    fluid
                    onInput={(e, value) => {
                      setTextInput(value);
                      setTextInputHistoryIndex(textInputHistory.length);
                    }}
                    onKeyDown={(e) => {
                      if (e.key === 'Enter') {
                        act('text', { value: textInput });
                        appendHistory(textInput);
                        setTextInput("");
                      } else if (e.key === 'Up') {
                        navigateHistory(-1, e.target);
                      } else if (e.key === 'Down') {
                        navigateHistory(1, e.target);
                      }
                    }}
                    mr="0.5rem"
                  />
                </Flex.Item>
                <Flex.Item>
                  <Tooltip content="Enter">
                    <Button icon="share"
                      color={TermActive ? "green" : "red"}
                      onClick={() => {
                        act('text', { value: textInput });
                        appendHistory(textInput);
                        setTextInput("");
                      }}
                      mr="0.5rem" />
                  </Tooltip>
                </Flex.Item>
                <Flex.Item>
                  <Tooltip content="Restart">
                    <Button icon="repeat"
                      color={TermActive ? "green" : "red"}
                      onClick={() => act('restart')} />
                  </Tooltip>
                </Flex.Item>
              </Flex>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section fitted>
              {peripherals.map(peripheral => {
                return (
                  <Button
                    key={peripheral.card}
                    icon={peripheral.icon}
                    content={peripheral.label}
                    fontFamily={peripheral.Clown ? "Comic Sans MS" : "Consolas"}
                    color={peripheral.color ? "green" : "grey"}
                    onClick={() => act('buttonPressed', {
                      card: peripheral.card, index: peripheral.index })}
                  />
                );
              })}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
      {handleScrollBottom()}
    </Window>
  );

};
