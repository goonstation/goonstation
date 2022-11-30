import { useBackend } from '../backend';
import { Box, Button, Flex, Section, Image, Stack, ByondUi } from '../components';
import { Window } from '../layouts';

export const BarberingMenu = (props, context) => {
  const { data } = useBackend(context);
  const { available_styles } = data;

  const styles_keys = Object.keys(available_styles);
  return (
    <Window
      width={700}
      height={500}
      title="Barber">

      <Window.Content scrollable>
        <HairOptions />
        <hr />
        <Stack>
          <Stack.Item width="69%">
            <Stack wrap="wrap" justify="space-around">
              {styles_keys.map((value, index) => (<HairPreview
                key={index}
                hair_style={available_styles[value]}
                hair_name={value} />))}
            </Stack>
          </Stack.Item>
          <Stack.Item width="2%">
            <Box style={{ "background-color": "white", "height": "100%", "width": "1px" }} />
          </Stack.Item>
          <Stack.Item position="fixed" width="29%">
            <PreviewWindow />
          </Stack.Item>
        </Stack>
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
    <Stack justify="space-between" fontSize="15px">
      <Button.Checkbox checked={selected_hair_portion === bottom ? 1 : 0} onClick={() => act("change_hair_portion", { "new_portion": bottom })}>Bottom Hair</Button.Checkbox>
      <Button.Checkbox checked={selected_hair_portion === middle ? 1 : 0} onClick={() => act("change_hair_portion", { "new_portion": middle })}>Middle Hair</Button.Checkbox>
      <Button.Checkbox checked={selected_hair_portion === top ? 1 : 0} onClick={() => act("change_hair_portion", { "new_portion": top })}>Top Hair</Button.Checkbox>
      <hr />
      <Button bold color="red" icon="cut" onClick={() => act("do_hair", { "style_id": null })}>Create Wig</Button>
    </Stack>
  );
};

const HairPreview = (props, context) => {
  const { act } = useBackend(context);
  const { hair_style, hair_name } = props;
  return (
    <Section width="120px" direction="column" align="center">
      <Image pixelated width="60px" height="100px" src={`${hair_style["hair_icon"]}`} />
      <Box width="100%" fontSize="15px" textAlign="center" pb="10px">{hair_name}</Box>
      <Stack inline justify="space-between">
        <Button color="blue" fontSize="11px" height="20px" icon="cut" onClick={() => act("do_hair", { "style_id": hair_style["hair_id"] })}>Cut</Button>
        <Button color="blue" fontSize="11px" height="20px" icon="eye" onClick={() => act("update_preview", { "what_to_do": "new_hair", "style_id": hair_style["hair_id"] })}>Preview</Button>
      </Stack>
    </Section>
  );
};

const PreviewWindow = (props, context) => {
  const { act, data } = useBackend(context);
  const { preview, current_hair_style } = data;
  return (
    <Section>
      <Button icon="rotate-left" color="red" width="100%" onClick={() => act("update_preview", { "what_to_do": "reset" })}>Reset</Button>
      <Stack justify="space-around">
        <ByondUi
          params={{
            id: preview,
            type: "map",
          }}
          style={{
            width: "80px",
            height: "160px",
          }} />
      </Stack>
      <Stack wrap="wrap" align="center">
        <Box p="1px solid black" bold>Top Hair: {current_hair_style[0]}</Box>
        <Box p="1px solid black" bold>Middle Hair: {current_hair_style[1]}</Box>
        <Box p="1px solid black" bold>Bottom Hair: {current_hair_style[2]}</Box>
      </Stack>
    </Section>
  );
};
