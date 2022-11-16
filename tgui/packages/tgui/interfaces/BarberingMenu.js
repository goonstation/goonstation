import { useBackend } from '../backend';
import { Box, Button, Flex, Section, Image, Stack } from '../components';
import { Window } from '../layouts';

export const BarberingMenu = (props, context) => {
  const { data } = useBackend(context);
  const { hairstyles } = data;

  return (
    <Window
      width={700}
      height={500}
      title="Barber">

      <Window.Content>
        <HairOptions />
        <hr />
        <HairPreview hair_style={hairstyles["haircuts"]["Clown"]} />
      </Window.Content>
    </Window>
  );
};

const HairOptions = (props, context) => {
  const { act, data } = useBackend(context);
  const { selected_hair_portion } = data;

  // Theses are macros in the `code\datums\components\barber.dm` file.
  const all_hair = 4;
  const top = 3;
  const middle = 2;
  const bottom = 1;

  return (
    <Flex justify={"space-between"} fontSize={"15px"}>
      <Button.Checkbox checked={selected_hair_portion === bottom ? 1 : 0} onClick={() => act("change_hair_portion", { "new_portion": bottom })}>Bottom Hair</Button.Checkbox>
      <Button.Checkbox checked={selected_hair_portion === middle ? 1 : 0} onClick={() => act("change_hair_portion", { "new_portion": middle })}>Middle Hair</Button.Checkbox>
      <Button.Checkbox checked={selected_hair_portion === top ? 1 : 0} onClick={() => act("change_hair_portion", { "new_portion": top })}>Top Hair</Button.Checkbox>
      <hr />
      <Button color="red" bold={1} icon="cut" onClick={() => act("do_hair", { "style_id": null })}>Create Wig</Button>
    </Flex>
  );
};

const HairPreview = (props, context) => {
  const { act } = useBackend(context);
  const { hair_style } = props;
  return (
    <Section width="80px" height="112px">
      <Stack width="100%" align="center">
        <Image pixelated width="50px" height="72px" src={`${hair_style["hair_icon"]}`} />
      </Stack>
      <Box width="100%" textAlign="center">Clown</Box>
    </Section>
  );
};
