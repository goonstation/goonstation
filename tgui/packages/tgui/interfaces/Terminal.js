import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Box, Input, Button, Section } from 'tgui/components';

export const Terminal = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    fdisk,
    idcard,
    temp,
    TermActive,
  } = data;
  const { textInput } = props;
  return (
    <Window theme="retro-dark" scrollable
      title="Dwaine Terminal"
      width="380"
      height="350">
      <Section scrollable mt="1em" width="95%" mx="1em" height="70%" mb="1em" inline fitted>
        <Box mx="1em" mr="1em" textalign="left" preserveWhitespace="true" color="#008000">
          {temp}
        </Box>
      </Section>
      <Section mb="5em" fitted>
        <Input
          mt="1em"
          id="keyboard"
          autoFocus
          selfClear
          value={textInput}
          width="80%"
          onChange={(e, value) => act('text', { value: value })}
        />
        <Button icon="power-off" color={TermActive ? 'green' : 'red'} mr="0.2em" mb="1em" onClick={() => act('restart')} />
        <Button icon="fa-solid fa-floppy-disk" mr="0.2em" mb="2em" />
      </Section>
      <Window.Content />
    </Window>
  );

};
