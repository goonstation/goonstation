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
import { MinimapControllerData, MinimapMarkerData } from './MinimapController';

export const GeneralAlert = () => {
  const { data, act } = useBackend<MinimapControllerData>();
  const { title, theme, minimap_id, minimap_markers } = data;

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
                  {Object.values(minimap_markers).map((marker) => (
                    <MinimapIconMarker
                      name={marker.name}
                      pos={marker.pos}
                      visible={marker.visible}
                      can_be_deleted={marker.can_be_deleted}
                      icon_state={marker.icon_state}
                      index={marker.index}
                      marker={marker.marker}
                      key={marker.index}
                    />
                  ))}
                </Flex.Item>
              </Flex>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MinimapIconMarker = (markerData: MinimapMarkerData) => {
  const { data } = useBackend<MinimapControllerData>();
  const { placable_marker_states, placable_marker_images } = data;
  return (
    <Stack>
      <Stack.Item>
        {placable_marker_states[markerData.icon_state] !== null && (
          <Image
            align="right"
            height="40px"
            width="40px"
            style={{
              msTransform: 'scale(1.5)',
            }}
            src={`data:image/png;base64,${placable_marker_images[markerData.icon_state]}`}
          />
        )}
      </Stack.Item>
      <Stack.Item grow>
        <Flex className="minimap-controller__marker-list" height={3}>
          <Flex.Item inline>
            <Flex.Item fontSize={1.1} bold>
              {capitalize(markerData.name)}
            </Flex.Item>
            <Flex.Item>{markerData.pos}</Flex.Item>
          </Flex.Item>
        </Flex>
      </Stack.Item>
    </Stack>
  );
};
