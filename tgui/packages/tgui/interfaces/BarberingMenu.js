import { useBackend } from '../backend';
import { Box, Button, Section, Image, Stack, ByondUi } from '../components';
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
          <Stack.Item width="65%">
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

  return (
    <Stack justify="space-between" fontSize="15px">
      <Button.Checkbox checked={selected_hair_portion === "bottom" ? 1 : 0} onClick={() => act("change_hair_portion", { "new_portion": "bottom" })}>Bottom Hair</Button.Checkbox>
      <Button.Checkbox checked={selected_hair_portion === "middle" ? 1 : 0} onClick={() => act("change_hair_portion", { "new_portion": "middle" })}>Middle Hair</Button.Checkbox>
      <Button.Checkbox checked={selected_hair_portion === "top" ? 1 : 0} onClick={() => act("change_hair_portion", { "new_portion": "top" })}>Top Hair</Button.Checkbox>
      <hr />
      <Button bold color="red" icon="cut" onClick={() => act("do_hair", { "style_id": null })}>Create Wig</Button>
    </Stack>
  );
};

const HairPreview = (props, context) => {
  const { act, data } = useBackend(context);
  const { hair_style, hair_name } = props;
  return (
    <Section width="140px" direction="column" align="center">
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

      <Stack justify="space-around" height="200px" wrap="wrap">
        <Button icon="rotate-left" color="red" height="22px" width="100%" onClick={() => act("update_preview", { "what_to_do": "reset" })}>Reset</Button>
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
      <hr />
      <Stack wrap="wrap" height="50px" align="center">
        <Box p="1px solid black" bold>Top Hair: {current_hair_style["top"]}</Box>
        <Box p="1px solid black" bold>Middle Hair: {current_hair_style["middle"]}</Box>
        <Box p="1px solid black" bold>Bottom Hair: {current_hair_style["bottom"]}</Box>
      </Stack>
      <hr />
      <Stack width="100%" align="center" wrap="wrap" justify="space-around">
        <Button icon="caret-up" onClick={() => act("update_preview", { "what_to_do": "change_direction", "direction": "north" })} />
        <Stack width="100%" align="center" justify="space-around">
          <Button icon="caret-left" onClick={() => act("update_preview", { "what_to_do": "change_direction", "direction": "west" })} />
          <Button icon="caret-right" onClick={() => act("update_preview", { "what_to_do": "change_direction", "direction": "east" })} />
        </Stack>
        <Button icon="caret-down" onClick={() => act("update_preview", { "what_to_do": "change_direction", "direction": "south" })} />
      </Stack>
    </Section>
  );
};
