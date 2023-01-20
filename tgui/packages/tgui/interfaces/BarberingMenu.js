import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Image, Stack, ByondUi, Input, Icon } from '../components';
import { Window } from '../layouts';

export const BarberingMenu = (props, context) => {
  const { data } = useBackend(context);
  const { available_styles } = data;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

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
          <Stack.Item width="70%">
            <Stack wrap="wrap" justify="space-around">
              <Stack width="100%" inline justify="space-around">
                <Icon name="magnifying-glass" />
                <Stack.Item mb="10px" grow>
                  <Input width="100%" onInput={(e, value) => setSearchText(value)} />
                </Stack.Item>
              </Stack>
              <HairPreviewList search_text={searchText}
                all_hair_names={styles_keys}
                all_hair_styles={available_styles} />
            </Stack>
          </Stack.Item>
          <Stack.Item position="fixed" width="200px">
            <PreviewWindow />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const HairPreviewList = function (props, context) {
  const { search_text, all_hair_names, all_hair_styles } = props;

  const filtered_list = all_hair_names.filter((x) => x.toLowerCase().includes(search_text.toLowerCase()));
  return filtered_list.map((hairName) => (<HairPreview
    key={all_hair_styles[hairName].id}
    hair_style={all_hair_styles[hairName]}
    hair_name={hairName} />));
};

const HairOptions = (props, context) => {
  const { act, data } = useBackend(context);
  const { selected_hair_portion } = data;

  return (
    <Stack justify="space-between" fontSize="15px">
      <Stack.Item>
        <Button.Checkbox mx="20px" checked={selected_hair_portion === "bottom" ? 1 : 0} onClick={() => act("change_hair_portion", { "new_portion": "bottom" })}>Bottom Hair</Button.Checkbox>
        <Button.Checkbox mx="20px" checked={selected_hair_portion === "middle" ? 1 : 0} onClick={() => act("change_hair_portion", { "new_portion": "middle" })}>Middle Hair</Button.Checkbox>
        <Button.Checkbox mx="20px" checked={selected_hair_portion === "top" ? 1 : 0} onClick={() => act("change_hair_portion", { "new_portion": "top" })}>Top Hair</Button.Checkbox>
      </Stack.Item>
      <Stack.Item width="2px">
        <Box backgroundColor="white" width="2px" height="100%" />
      </Stack.Item>
      <Stack.Item shrink>
        <Button bold color="red" icon="cut" onClick={() => act("do_hair", { "style_id": null })}>Create Wig</Button>
      </Stack.Item>
    </Stack>
  );
};

const HairPreview = (props, context) => {
  const { act, data } = useBackend(context);
  const { hair_style, hair_name } = props;
  return (
    <Section width="140px" direction="column" align="center">
      <Stack inline justify="space-between">
        <Stack.Item>
          <Image pixelated width="60px" height="100px" src={`${hair_style["hair_icon"]}`} />
          <Box width="100%" fontSize="15px" textAlign="center" mb="10px">{hair_name}</Box>
          <Button color="blue" height="20px" icon="cut" onClick={() => act("do_hair", { "style_id": hair_style["hair_id"] })}>Cut</Button>
          <Button color="blue" height="20px" icon="eye" onClick={() => act("update_preview", { "action": "new_hair", "style_id": hair_style["hair_id"] })}>Preview</Button>
        </Stack.Item>
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
        <Stack.Item width="100%">
          <Button icon="rotate-left" color="red" height="22px" width="100%" onClick={() => act("update_preview", { "action": "reset" })}>Reset</Button>
        </Stack.Item>
        <Stack.Item>
          <ByondUi
            params={{
              id: preview,
              type: "map",
            }}
            style={{
              width: "80px",
              height: "160px",
            }} />
        </Stack.Item>
      </Stack>
      <hr />
      <Stack wrap="wrap" align="center">
        <Stack.Item>
          <Box width="100%" bold>Top Hair: {current_hair_style["top"]}</Box>
          <Box width="100%" bold>Middle Hair: {current_hair_style["middle"]}</Box>
          <Box width="100%" bold>Bottom Hair: {current_hair_style["bottom"]}</Box>
        </Stack.Item>
      </Stack>
      <hr />
      <Stack width="100%" align="center" wrap="wrap" justify="space-around">
        <Stack.Item>
          <Button icon="caret-up" onClick={() => act("update_preview", { "action": "change_direction", "direction": "north" })} />
        </Stack.Item>
        <Stack width="100%" align="center" justify="space-around">
          <Stack.Item>
            <Button icon="caret-left" onClick={() => act("update_preview", { "action": "change_direction", "direction": "west" })} />
          </Stack.Item>
          <Stack.Item>
            <Button icon="caret-right" onClick={() => act("update_preview", { "action": "change_direction", "direction": "east" })} />
          </Stack.Item>
        </Stack>
        <Stack.Item>
          <Button icon="caret-down" onClick={() => act("update_preview", { "action": "change_direction", "direction": "south" })} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};
