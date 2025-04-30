/**
 * @file
 * @copyright 2023 Caio029 (https://github.com/caiofrancisco)
 * @license MIT
 */
import { useState } from 'react';
import {
  Box,
  Button,
  ByondUi,
  Icon,
  Image,
  Input,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const sidebarWidth = '200px';

interface BarberingMenuData {
  available_styles;
  current_hair_style;
  preview;
  selected_hair_portion;
}

export const BarberingMenu = () => {
  const { data } = useBackend<BarberingMenuData>();
  const [searchText, setSearchText] = useState('');
  const { available_styles } = data;

  const styles_keys = Object.keys(available_styles);

  return (
    <Window width={700} height={500} title="Barber">
      <Window.Content scrollable m={0}>
        <Stack>
          <Stack.Item width={sidebarWidth}>
            <Box position="fixed" width={sidebarWidth}>
              <Sidebar onSearchTextInput={setSearchText} />
            </Box>
          </Stack.Item>
          <Stack.Item grow>
            <HairPreviewList
              searchText={searchText}
              allHairNames={styles_keys}
              allHairStyles={available_styles}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const HairStyleSearchBox = (props) => {
  const { onInput } = props;
  return (
    <Stack>
      <Stack.Item>
        <Icon name="magnifying-glass" />
      </Stack.Item>
      <Stack.Item grow>
        <Input
          style={{ width: '100%' }}
          onInput={(value) => onInput(value)}
          placeholder="Search..."
        />
      </Stack.Item>
    </Stack>
  );
};

const HairPreviewList = (props) => {
  const { searchText, allHairNames, allHairStyles } = props;
  const lowerSearchText = searchText.toLowerCase();
  const filteredList = allHairNames.filter((x) =>
    x.toLowerCase().includes(lowerSearchText),
  );
  return (
    <Stack wrap>
      {filteredList.map((hairName) => (
        <Stack.Item key={allHairStyles[hairName].id} m={1}>
          <HairPreview
            hairStyle={allHairStyles[hairName]}
            hairName={hairName}
          />
        </Stack.Item>
      ))}
    </Stack>
  );
};

const CreateWigButton = () => {
  const { act } = useBackend<BarberingMenuData>();
  return (
    <Button
      fluid
      icon="cut"
      color="red"
      bold
      onClick={() => act('do_hair', { style_id: null })}
    >
      Create Wig
    </Button>
  );
};

const ResetPreviewButton = () => {
  const { act } = useBackend<BarberingMenuData>();
  return (
    <Button
      fluid
      icon="rotate-left"
      color="red"
      onClick={() => act('update_preview', { action: 'reset' })}
    >
      Reset
    </Button>
  );
};

const HairPreview = (props) => {
  const { act } = useBackend<BarberingMenuData>();
  const { hairStyle, hairName } = props;
  return (
    <Section width="140px" align="center">
      <Stack vertical>
        <Stack.Item>
          <Image
            width="60px"
            height="100px"
            src={`${hairStyle['hair_icon']}`}
          />
        </Stack.Item>
        <Stack.Item>{hairName}</Stack.Item>
        <Stack.Item>
          <Button
            color="blue"
            icon="cut"
            onClick={() => act('do_hair', { style_id: hairStyle['hair_id'] })}
          >
            Cut
          </Button>
          <Button
            color="blue"
            icon="eye"
            onClick={() =>
              act('update_preview', {
                action: 'new_hair',
                style_id: hairStyle['hair_id'],
              })
            }
          >
            Preview
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const ArrowButtons = () => {
  const { act } = useBackend();
  return (
    <Stack justify="space-around">
      <Stack.Item align="center">
        <Button
          icon="rotate-left"
          onClick={() =>
            act('update_preview', {
              action: 'change_direction',
              direction: -90,
            })
          }
        />
      </Stack.Item>
      <Stack.Item align="center">
        <Button
          icon="rotate-right"
          onClick={() =>
            act('update_preview', { action: 'change_direction', direction: 90 })
          }
        />
      </Stack.Item>
    </Stack>
  );
};

const Sidebar = (props) => {
  const { data } = useBackend<BarberingMenuData>();
  const { preview } = data;
  const { onSearchTextInput } = props;
  return (
    <Section>
      <Stack vertical>
        <Stack.Item>
          <HairStyleSearchBox onInput={onSearchTextInput} />
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <HairPortionList />
        </Stack.Item>
        <Stack.Divider mt={0} />
        <Stack.Item align="center" style={{ width: '100%' }}>
          <Box style={{ width: '100%' }} align="center">
            <ByondUi
              params={{
                id: preview,
                type: 'map',
              }}
              style={{
                width: '80px',
                height: '160px',
              }}
            />
          </Box>
          <ResetPreviewButton />
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <ArrowButtons />
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <CreateWigButton />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const HairPortionItem = (props) => {
  const { children, hairPortion, icon } = props;
  const { act, data } = useBackend<BarberingMenuData>();
  const { current_hair_style, selected_hair_portion } = data;
  const rightSlot = <Box align="right">{current_hair_style[hairPortion]}</Box>;
  return (
    <Tabs.Tab
      icon={icon}
      rightSlot={rightSlot}
      selected={selected_hair_portion === hairPortion}
      onClick={() => act('change_hair_portion', { new_portion: hairPortion })}
    >
      {children}
    </Tabs.Tab>
  );
};

const HairPortionList = () => {
  return (
    <Tabs vertical mb={0}>
      <HairPortionItem hairPortion="top" icon="arrows-up-to-line">
        Top
      </HairPortionItem>
      <HairPortionItem hairPortion="middle" icon="arrow-down-up-across-line">
        Middle
      </HairPortionItem>
      <HairPortionItem hairPortion="bottom" icon="arrows-down-to-line">
        Bottom
      </HairPortionItem>
    </Tabs>
  );
};
