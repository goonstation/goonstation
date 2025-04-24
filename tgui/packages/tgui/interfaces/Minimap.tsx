import { ByondUi } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface MinimapData {
  minimap_id;
  theme;
  title;
}

export const Minimap = () => {
  const { data } = useBackend<MinimapData>();
  const { title, theme, minimap_id } = data;

  return (
    <Window title={title} theme={theme} width={610} height={640}>
      <Window.Content>
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
      </Window.Content>
    </Window>
  );
};
