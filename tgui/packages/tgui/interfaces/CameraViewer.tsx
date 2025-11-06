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
  Input,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { capitalize } from './common/stringUtils';
import { MinimapControllerData, MinimapMarkerData } from './MinimapController';

export const CameraViewer = () => {
  const { data, act } = useBackend<MinimapControllerData>();
  const { title, theme, minimap_id, minimap_markers } = data;
  const [search, setSearch] = useSharedState('search', '');
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
                  'right-click': true,
                  letterbox: false,
                }}
                width="600px"
                height="600px"
              />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section scrollable fill title="Cameras">
              <LabeledList>
                <LabeledList.Item label="Search">
                  <Input
                    value={search}
                    onChange={(value) => setSearch(value)}
                  />
                </LabeledList.Item>
              </LabeledList>
              {sortedMarkers.map((marker) => (
                <SearchableMinimapIconMarker
                  key={marker.name}
                  search={search}
                  {...marker}
                />
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type SearchableMinimapIconMarkerProps = MinimapMarkerData & { search: string };

const SearchableMinimapIconMarker = (
  props: SearchableMinimapIconMarkerProps,
) => {
  const { search, name, pos, target_ref } = props;
  const { act } = useBackend<MinimapControllerData>();

  if (search && name && !name.toLowerCase().includes(search.toLowerCase())) {
    return null;
  }

  return (
    <Stack>
      <Stack.Item>
        <Button
          className="minimap-controller__buttons"
          icon="eye"
          onClick={() =>
            act('view_camera', {
              target_ref,
            })
          }
        />
      </Stack.Item>
      <Stack.Item grow>
        <Flex className="minimap-controller__marker-list" height={3}>
          <Flex.Item>
            <Box bold>{capitalize(name)}</Box>
            <Box>{pos}</Box>
          </Flex.Item>
        </Flex>
      </Stack.Item>
    </Stack>
  );
};
