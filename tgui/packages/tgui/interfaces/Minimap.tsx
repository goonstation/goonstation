import { BooleanLike } from 'common/react';
import {
  Box,
  Button,
  ByondUi,
  Dropdown,
  Flex,
  NoticeBox,
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
  is_loading?: BooleanLike;
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
    is_loading,
  } = data;
  const zLevelLabels = Object.keys(z_level_options || {});
  const selectedZLevel = zLevelLabels?.find(
    (label) => z_level_options?.[label] === z_level,
  );
  const isAdminMinimap = !!z_level_options;
  const playersVisible = !!show_players;
  const observersVisible = !!show_observers;
  const isLoading = !!is_loading;

  return (
    <Window
      title={title}
      theme={theme}
      width={z_level_options ? 830 : 610}
      height={640}
    >
      <Window.Content>
        <Stack>
          <Stack.Item>
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
          </Stack.Item>
          {isAdminMinimap && (
            <Stack.Item style={{ width: '210px' }}>
              <Section title="Map Controls">
                <Stack vertical fill>
                  <Button
                    fluid
                    icon="undo"
                    color="green"
                    onClick={() => act('reset_scale')}
                  >
                    Reset Zoom &amp; Pan
                  </Button>
                  <Button
                    fluid
                    icon="refresh"
                    color="blue"
                    disabled={isLoading}
                    onClick={() => act('refresh_map')}
                  >
                    Refresh Current Z-Level
                  </Button>
                  <Button
                    fluid
                    icon={playersVisible ? 'eye' : 'eye-slash'}
                    color={playersVisible ? 'green' : 'red'}
                    onClick={() => act('toggle_players')}
                  >
                    Show Players
                  </Button>
                  <Button
                    fluid
                    icon={observersVisible ? 'eye' : 'eye-slash'}
                    color={observersVisible ? 'green' : 'red'}
                    onClick={() => act('toggle_observers')}
                  >
                    Show Observers
                  </Button>
                  <Stack.Item>
                    <Box color="label" textAlign="center">
                      Scroll to zoom. Drag to pan. Click to teleport.
                    </Box>
                  </Stack.Item>
                  {isLoading && (
                    <Stack.Item>
                      <NoticeBox info textAlign="center">
                        Generating minimap, please wait...
                      </NoticeBox>
                    </Stack.Item>
                  )}
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
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
