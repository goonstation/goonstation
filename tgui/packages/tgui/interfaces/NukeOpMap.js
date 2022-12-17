import { useBackend } from '../backend';
import { Box, Button, ByondUi, Flex, Section, Stack } from '../components';
import { Window } from '../layouts';
import { capitalize } from './common/stringUtils';

export const NukeOpMap = (params, context) => {
  const { act, data } = useBackend(context);
  const {
    markers_visible,
    minimap_markers,
  } = data;
  return (
    <Window
      theme="syndicate"
      title="Atrium Station Map Controller"
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
                  onClick={() => act('reset_scale')} />
              )}>
              <Flex>
                <Flex.Item>
                  <ByondUi
                    params={{
                      id: "nukeop_map",
                      type: 'map',
                    }}
                    style={{
                      width: "300px",
                      height: "300px",
                    }} />
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
                    onClick={() => act('new_marker')} />
                  <Button
                    icon={markers_visible ? "eye-slash" : "eye"}
                    color={markers_visible ? "red" : "green"}
                    content={markers_visible ? "Hide All" : "Show All"}
                    onClick={() => act('toggle_visibility_all')} />
                </Box>
              )}>
              <Section scrollable fill>
                <Flex direction="column">
                  <Flex.Item>
                    <Flex.Item>
                      {Object.keys(minimap_markers).map(marker => (
                        <Flex key={data.minimap_markers[marker]}
                          backgroundColor={"rgba(30, 0, 0, 0.4)"}
                          justify="space-between"
                          p="5px"
                          pb="1px"
                          mb="4px"
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
                              icon={data.minimap_markers[marker].visible ? "eye" : "eye-slash"}
                              color={data.minimap_markers[marker].visible ? "green" : "red"}
                              fontSize={1.7}
                              onClick={() => act('toggle_visibility', { index: data.minimap_markers[marker].index })}
                            />
                            <Button
                              icon="trash-alt"
                              color="red"
                              disabled={!data.minimap_markers[marker].can_be_deleted}
                              fontSize={1.7}
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
