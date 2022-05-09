import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Box, Input, Button, Section } from 'tgui/components';
import { ColorBox, Flex } from '../components';

export const Terminal = (props, context) => {
  const { act, data } = useBackend(context);
  const peripherals = data.peripherals || [];
  const { textInput } = props;

  const {
    fdisk,
    idcard,
    displayHTML,
    TermActive,
    windowName,
    user,
    fontColor,
    bgColor,
    diskdrive,
  } = data;

  return (
    <Window
      theme="retro-dark"
      title={windowName}
      width="380"
      fontFamily="Consolas"
      font-size="10pt"
      height="350">
      <Window.Content>
        <Section backgroundColor="#0f0f0f" scrollable fill height="70%" >
          <Box color={fontColor} backgroundColor={bgColor} minHeight="99%" maxHeight="500em">
            <Box mx="1%"
              fontFamily="Consolas"
              fill
              color={fontColor}
              backgroundColor={bgColor}
              dangerouslySetInnerHTML={{ __html: displayHTML }}
            />
          </Box>
        </Section>
        <Section mt="1%" fitted>
          <Input
            as="span"
            placeholder="Type Here"
            selfClear
            value={textInput}
            width="80%"
            mt="1%"
            ml="1%"
            onChange={(e, value) => act('text', { value: value })}
          />
          <Button ml="11%" icon="power-off"
            color={data.TermActive ? "green" : "red"}
            onClick={() => act('restart')} />
        </Section>
        <Section fitted fill height="20%">
          {peripherals.map(peripheral => {
            return (
              <Button
                ml="1%"
                mt="8%"
                mb="5%"
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
      </Window.Content>
    </Window>
  );

};
