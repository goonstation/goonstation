import { BooleanLike } from 'common/react';
import { useState } from 'react';
import {
  Box,
  Button,
  ByondUi,
  Dropdown,
  Flex,
  Image,
  Input,
  Modal,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { capitalize } from './common/stringUtils';

export interface MinimapControllerData {
  title: string;
  theme: string;
  minimap_id: string;
  markers_visible: BooleanLike;
  selecting_coordinates: BooleanLike;
  minimap_markers: MinimapMarkerData[];
  placable_marker_states: string[]; // list of indexes in placable_marker_images
  placable_marker_images: Map<string, string>; // indexed base64 images
  icon: string;
  image: string; // base64 image
  pos_x: number;
  pos_y: number;
}

export interface MinimapMarkerData {
  name: string;
  pos: string;
  visible: BooleanLike;
  can_be_deleted: BooleanLike;
  marker: string;
  index: number;
  icon_state: string;
}

export const MinimapController = () => {
  const { act, data } = useBackend<MinimapControllerData>();
  const {
    title,
    theme,
    minimap_id,
    markers_visible,
    selecting_coordinates,
    minimap_markers,
    placable_marker_states,
    placable_marker_images,
    icon,
    image,
    pos_x,
    pos_y,
  } = data;

  const [name, setName] = useState('');
  const [showNewMarkerMenu, toggleNewMarkerMenu] = useState(false);

  const newMarker = () => {
    toggleNewMarkerMenu(!showNewMarkerMenu);
    act('new_marker', {
      name: name,
      icon: icon,
      pos_x: pos_x,
      pos_y: pos_y,
    });
  };

  const cancelNewMarker = () => {
    toggleNewMarkerMenu(!showNewMarkerMenu);
    act('cancel_new_marker');
  };

  const setImage = (value) => {
    data.icon = value;
    data.image = placable_marker_images[value];
    act('update_icon', { icon: value });
  };

  const setPosX = (value) => {
    data.pos_x = value;
  };

  const setPosY = (value) => {
    data.pos_y = value;
  };

  return (
    <Window title={title} theme={theme} width={750} height={390}>
      <Window.Content>
        <Stack justify="center">
          <Stack.Item>
            <Section
              title="Minimap"
              fill
              buttons={
                <Button
                  icon="undo"
                  color="green"
                  onClick={() => act('reset_scale')}
                >
                  Reset Map Scale
                </Button>
              }
            >
              <Flex>
                <Flex.Item>
                  <ByondUi
                    params={{
                      id: minimap_id,
                      type: 'map',
                    }}
                    style={{
                      width: '300px',
                      height: '300px',
                    }}
                  />
                </Flex.Item>
              </Flex>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              title="Minimap Markers"
              fill
              buttons={
                <>
                  <Button
                    icon="plus"
                    color="green"
                    onClick={() => toggleNewMarkerMenu(!showNewMarkerMenu)}
                  >
                    New
                  </Button>
                  <Button
                    icon={markers_visible ? 'eye-slash' : 'eye'}
                    color={markers_visible ? 'red' : 'green'}
                    onClick={() => act('toggle_visibility_all')}
                  >
                    {markers_visible ? 'Hide All' : 'Show All'}
                  </Button>
                </>
              }
            >
              {!!showNewMarkerMenu && (
                <Modal mr={2}>
                  <Box>
                    <Flex>
                      <Flex.Item backgroundColor="black">
                        <Image
                          height="150px"
                          width="150px"
                          src={`data:image/png;base64,${image}`}
                        />
                      </Flex.Item>
                      <Flex.Item ml="10px">
                        <Input
                          placeholder="Marker Name"
                          fluid
                          value={name}
                          onChange={(e, value) => setName(value)}
                        />
                        <Dropdown
                          selected={icon}
                          width="150px"
                          options={placable_marker_states}
                          onSelected={(value) => setImage(value)}
                          mt="10px"
                        />
                        <Flex mt="10px" justify="space-between">
                          <Flex.Item>
                            <NumberInput
                              className="minimap-controller__number-inputs"
                              minValue={1}
                              maxValue={300}
                              step={1}
                              value={pos_x}
                              format={(value) => 'x, ' + value}
                              onDrag={(value) => setPosX(value)}
                            />
                          </Flex.Item>
                          <Flex.Item>
                            <NumberInput
                              className="minimap-controller__number-inputs"
                              minValue={1}
                              maxValue={300}
                              step={1}
                              value={pos_y}
                              format={(value) => 'y, ' + value}
                              onDrag={(value) => setPosY(value)}
                            />
                          </Flex.Item>
                        </Flex>
                        <Button
                          fluid
                          textAlign="center"
                          color={selecting_coordinates ? 'orange' : 'default'}
                          onClick={() => act('location_from_minimap')}
                          mt="10px"
                        >
                          {selecting_coordinates
                            ? 'Select Position'
                            : 'Select (x, y) From Map'}
                        </Button>
                        <Flex mt="20px" justify="space-between">
                          <Flex.Item>
                            <Button
                              icon="check"
                              color="green"
                              onClick={() => newMarker()}
                            >
                              Confirm
                            </Button>
                          </Flex.Item>
                          <Flex.Item>
                            <Button
                              icon="xmark"
                              color="red"
                              onClick={() => cancelNewMarker()}
                            >
                              Cancel
                            </Button>
                          </Flex.Item>
                        </Flex>
                      </Flex.Item>
                    </Flex>
                  </Box>
                </Modal>
              )}
              <Section scrollable fill>
                <Flex direction="column">
                  <Flex.Item>
                    <Flex.Item>
                      {Object.keys(minimap_markers).map((marker) => (
                        <Flex
                          key={data.minimap_markers[marker]}
                          className="minimap-controller__marker-list"
                        >
                          <Flex.Item inline>
                            <Flex.Item fontSize={1.1} bold>
                              {capitalize(data.minimap_markers[marker].name)}
                            </Flex.Item>
                            <Flex.Item inline lineHeight={1.7}>
                              {data.minimap_markers[marker].pos}
                            </Flex.Item>
                          </Flex.Item>
                          <Flex.Item inline>
                            <Button
                              className="minimap-controller__buttons"
                              icon={
                                data.minimap_markers[marker].visible
                                  ? 'eye'
                                  : 'eye-slash'
                              }
                              color={
                                data.minimap_markers[marker].visible
                                  ? 'green'
                                  : 'red'
                              }
                              onClick={() =>
                                act('toggle_visibility', {
                                  index: data.minimap_markers[marker].index,
                                })
                              }
                            />
                            <Button
                              className="minimap-controller__buttons"
                              icon="trash-alt"
                              color="red"
                              disabled={
                                !data.minimap_markers[marker].can_be_deleted
                              }
                              onClick={() =>
                                act('delete_marker', {
                                  index: data.minimap_markers[marker].index,
                                })
                              }
                            />
                          </Flex.Item>
                        </Flex>
                      ))}
                    </Flex.Item>
                  </Flex.Item>
                </Flex>
              </Section>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
