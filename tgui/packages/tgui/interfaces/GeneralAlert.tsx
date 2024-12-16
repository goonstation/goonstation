import {
  Button,
  ByondUi,
  Flex,
  Image,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { capitalize } from './common/stringUtils';

interface GeneralAlertData {
  title: string;
  theme: string;
  minimap_id: string;
  placable_marker_states;
  placable_marker_images;
  minimap_markers;
}

export const GeneralAlert = () => {
  const { data, act } = useBackend<GeneralAlertData>();
  const {
    title,
    theme,
    minimap_id,
    minimap_markers,
    placable_marker_states,
    placable_marker_images,
  } = data;

  return (
    <Window title={title} theme={theme} width={950} height={700}>
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
                      width: '600px',
                      height: '600px',
                    }}
                  />
                </Flex.Item>
              </Flex>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section scrollable fill title="Alerts">
              <Flex direction="column">
                <Flex.Item>
                  <Flex.Item>
                    {Object.keys(minimap_markers).map((marker) => (
                      <Stack key={data.minimap_markers[marker]}>
                        <Stack.Item>
                          {placable_marker_states[
                            data.minimap_markers[marker].icon_state
                          ] !== null && (
                            <Image
                              align="right"
                              height="40px"
                              width="40px"
                              style={{
                                msTransform: 'scale(1.5)',
                              }}
                              src={`data:image/png;base64,${placable_marker_images[data.minimap_markers[marker].icon_state]}`}
                            />
                          )}
                        </Stack.Item>
                        <Stack.Item grow>
                          <Flex className="minimap-controller__marker-list">
                            <Flex.Item inline>
                              <Flex.Item fontSize={1.1} bold>
                                {capitalize(data.minimap_markers[marker].name)}
                              </Flex.Item>
                              <Flex.Item inline lineHeight={1.7}>
                                {data.minimap_markers[marker].pos}
                              </Flex.Item>
                            </Flex.Item>
                          </Flex>
                        </Stack.Item>
                      </Stack>
                    ))}
                  </Flex.Item>
                </Flex.Item>
              </Flex>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
