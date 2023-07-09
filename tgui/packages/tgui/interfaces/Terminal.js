import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Box, Button, Flex, Input, Section, Stack } from '../components';

export const Terminal = (props, context) => {
  const { act, data } = useBackend(context);
  const peripherals = data.peripherals || [];
  const { textInput } = "";

  const {
    displayHTML,
    TermActive,
    windowName,
    fontColor,
    bgColor,
  } = data;

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
            <Section backgroundColor={bgColor} scrollable fill>
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
                  />
                </Flex.Item>
                <Flex.Item>
                  <Button icon="power-off"
                    color={TermActive ? "green" : "red"}
                    onClick={() => act('restart')} />
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
    </Window>
  );

};
