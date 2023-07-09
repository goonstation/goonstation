import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Box, Button, Flex, Input, Section, Stack, Tooltip } from '../components';

export const Terminal = (_props, context) => {
  const { act, data } = useBackend(context);
  const peripherals = data.peripherals || [];
  const { textInput } = "";

  const {
    displayHTML,
    TermActive,
    windowName,
    fontColor,
    bgColor,
    doScrollBottom,
  } = data;

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
                    onChange={(e, value) => act('text', { value: value })}
                    mr="0.5rem"
                  />
                </Flex.Item>
                <Flex.Item>
                  <Tooltip content="Enter">
                    <Button icon="share"
                      color={TermActive ? "green" : "red"}
                      onClick={() => act('text')}
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
                      card: peripheral.card })}
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
