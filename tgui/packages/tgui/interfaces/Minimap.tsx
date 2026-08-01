import { BooleanLike } from 'common/react';
import {
  Box,
  Button,
  ByondUi,
  Dropdown,
  Flex,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface MinimapData {
  minimap_id;
  theme;
  title;
  z_level_options?: Record<string, number>;
  z_level?: number;
  show_players?: BooleanLike;
  show_observers?: BooleanLike;
}

export const Minimap = () => {
  const { act, data } = useBackend<MinimapData>();
  const {
    title,
    theme,
    minimap_id,
    z_level_options,
    z_level,
    show_players,
    show_observers,
  } = data;
  const zLevelLabels = Object.keys(z_level_options || {});
  const selectedZLevel = zLevelLabels?.find(
    (label) => z_level_options?.[label] === z_level,
  );
  const isAdminMinimap = !!z_level_options;
  const playersVisible = !!show_players;
  const observersVisible = !!show_observers;

  return (
    <Window
      title={title}
      theme={theme}
      width={z_level_options ? 850 : 610}
      height={640}
    >
      <Window.Content>
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
          {isAdminMinimap && (
            <Flex.Item ml={1} style={{ width: '210px' }}>
              <Section title="Map Controls">
                <Stack vertical fill>
                  <Stack.Item>
                    <Button
                      fluid
                      icon="undo"
                      color="green"
                      onClick={() => act('reset_scale')}
                    >
                      Reset Zoom &amp; Pan
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      fluid
                      icon="refresh"
                      color="blue"
                      onClick={() => act('refresh_map')}
                    >
                      Refresh Current Z-Level
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      fluid
                      icon={playersVisible ? 'eye' : 'eye-slash'}
                      color={playersVisible ? 'green' : 'red'}
                      onClick={() => act('toggle_players')}
                    >
                      Show Players
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      fluid
                      icon={observersVisible ? 'eye' : 'eye-slash'}
                      color={observersVisible ? 'green' : 'red'}
                      onClick={() => act('toggle_observers')}
                    >
                      Show Observers
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Box color="label" textAlign="center">
                      Scroll to zoom. Drag to pan. Click to teleport.
                    </Box>
                  </Stack.Item>
                </Stack>
              </Section>
              <Section title="Z Level">
                <Flex justify="center">
                  <Dropdown
                    selected={selectedZLevel}
                    options={zLevelLabels}
                    onSelected={(value) =>
                      act('select_z_level', {
                        z_level: z_level_options[value],
                      })
                    }
                  />
                </Flex>
              </Section>
            </Flex.Item>
          )}
        </Flex>
      </Window.Content>
    </Window>
  );
};
