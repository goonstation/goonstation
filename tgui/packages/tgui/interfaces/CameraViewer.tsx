/**
 * @file
 * @copyright 2025
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import {
  Box,
  Button,
  ByondUi,
  Flex,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { capitalize } from './common/stringUtils';
import { MinimapControllerData, MinimapMarkerData } from './MinimapController';

export const CameraViewer = () => {
  const { data, act } = useBackend<MinimapControllerData>();
  const { title, theme, minimap_id, minimap_markers } = data;
  const sortedMarkers = Object.values(minimap_markers).sort((a, b) =>
    a.name.toUpperCase() < b.name.toUpperCase()
      ? -1
      : a.name.toUpperCase() > b.name.toUpperCase()
        ? 1
        : 0,
  );

  return (
    <Window title={title} theme={theme} width={950} height={700}>
      <Window.Content>
        <Stack>
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
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section scrollable fill title="Cameras">
              {sortedMarkers.map((marker) => (
                <MinimapIconMarker
                  name={marker.name}
                  pos={marker.pos}
                  visible={marker.visible}
                  can_be_deleted={marker.can_be_deleted}
                  icon_state={marker.icon_state}
                  index={marker.index}
                  marker={marker.marker}
                  key={marker.index}
                  target_ref={marker.target_ref}
                />
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MinimapIconMarker = (markerData: MinimapMarkerData) => {
  const { act } = useBackend<MinimapControllerData>();
  return (
    <Stack>
      <Stack.Item>
        <Button
          className="minimap-controller__buttons"
          icon="eye"
          onClick={() =>
            act('view_camera', {
              target_ref: markerData.target_ref,
            })
          }
        />
      </Stack.Item>
      <Stack.Item grow>
        <Flex className="minimap-controller__marker-list" height={3}>
          <Flex.Item>
            <Box bold>{capitalize(markerData.name)}</Box>
            <Box>{markerData.pos}</Box>
          </Flex.Item>
        </Flex>
      </Stack.Item>
    </Stack>
  );
};
