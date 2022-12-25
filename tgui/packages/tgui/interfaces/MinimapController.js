import { useBackend, useLocalState } from '../backend';
import { Box, Button, ByondUi, Dropdown, Flex, Image, Input, Modal, NumberInput, Section, Stack } from '../components';
import { Window } from '../layouts';
import { capitalize } from './common/stringUtils';

export const MinimapController = (params, context) => {
  const { act, data } = useBackend(context);
  const {
    title,
    theme,
    minimap_id,
    markers_visible,
    selecting_coordinates,
    minimap_markers,
    showNewMarkerMenu,
    placable_marker_states,
    placable_marker_images,
    icon,
    image,
    x,
    y,
  } = data;

  const [name, setName] = useLocalState(context, 'name');

  const toggleNewMarkerMenu = () => {
    data.showNewMarkerMenu = !showNewMarkerMenu;
  };

  const newMarker = () => {
    toggleNewMarkerMenu();
    act('new_marker', {
      name: name,
      icon: icon,
      pos_x: x,
      pos_y: y,
    });
  };

  const setImage = (value) => {
    data.icon = value;
    data.image = placable_marker_images[value];
  };

  const setX = (value) => {
    data.x = value;
  };

  const setY = (value) => {
    data.y = value;
  };

  return (
    <Window
      title={title}
      theme={theme}
      width={750}
      height={390}
    >
      <Window.Content>
        <Stack justify="center">
          <Stack.Item>
            <Section
              title="Minimap"
              fill
              buttons={(
                <Button
                  icon="undo"
                  color="green"
                  content="Reset Map Scale"
                  onClick={() => act('reset_scale')}
                />
              )}>
              <Flex>
                <Flex.Item>
                  <ByondUi
                    params={{
                      id: minimap_id,
                      type: 'map',
                    }}
                    style={{
                      width: "300px",
                      height: "300px",
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
              buttons={(
                <Box>
                  <Button
                    icon="plus"
                    color="green"
                    content="New"
                    onClick={() => toggleNewMarkerMenu()}
                  />
                  <Button
                    icon={markers_visible ? "eye-slash" : "eye"}
                    color={markers_visible ? "red" : "green"}
                    content={markers_visible ? "Hide All" : "Show All"}
                    onClick={() => act('toggle_visibility_all')}
                  />
                </Box>
              )}>
              {(!!showNewMarkerMenu) && (
                <Modal
                  mr={2}>
                  <Box>
                    <Flex>
                      <Flex.Item backgroundColor="black">
                        <Image
                          pixelated
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
                              value={x}
                              format={value => "x, " + value}
                              onDrag={(e, value) => setX(value)}
                            />
                          </Flex.Item>
                          <Flex.Item>
                            <NumberInput
                              className="minimap-controller__number-inputs"
                              minValue={1}
                              maxValue={300}
                              value={y}
                              format={value => "y, " + value}
                              onDrag={(e, value) => setY(value)}
                            />
                          </Flex.Item>
                        </Flex>
                        <Button
                          fluid
                          textAlign="center"
                          color={selecting_coordinates ? "orange" : "default"}
                          content={selecting_coordinates ? "Select Position" : "Select (x, y) From Map"}
                          onClick={() => act('location_from_minimap')}
                          mt="10px"
                        />
                        <Flex mt="20px" justify="space-between">
                          <Flex.Item>
                            <Button
                              icon="check"
                              color="green"
                              content="Confirm"
                              onClick={() => newMarker()}
                            />
                          </Flex.Item>
                          <Flex.Item>
                            <Button
                              icon="xmark"
                              color="red"
                              content="Cancel"
                              onClick={() => toggleNewMarkerMenu()}
                            />
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
                      {Object.keys(minimap_markers).map(marker => (
                        <Flex key={data.minimap_markers[marker]}
                          className="minimap-controller__marker-list"
                        >
                          <Flex.Item inline>
                            <Flex.Item
                              fontSize={1.1}
                              bold
                            >{capitalize(data.minimap_markers[marker].name)}
                            </Flex.Item>
                            <Flex.Item
                              inline
                              lineHeight={1.7}
                            >{data.minimap_markers[marker].pos}
                            </Flex.Item>
                          </Flex.Item>
                          <Flex.Item
                            inline
                          >
                            <Button
                              className="minimap-controller__buttons"
                              icon={data.minimap_markers[marker].visible ? "eye" : "eye-slash"}
                              color={data.minimap_markers[marker].visible ? "green" : "red"}
                              onClick={() => act('toggle_visibility', { index: data.minimap_markers[marker].index })}
                            />
                            <Button
                              className="minimap-controller__buttons"
                              icon="trash-alt"
                              color="red"
                              disabled={!data.minimap_markers[marker].can_be_deleted}
                              onClick={() => act('delete_marker', { index: data.minimap_markers[marker].index })}
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
