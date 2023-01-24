import { useBackend } from '../backend';
import { ByondUi } from '../components';
import { Window } from '../layouts';

export const Minimap = (params, context) => {
  const { data } = useBackend(context);
  const {
    title,
    theme,
    minimap_id,
  } = data;

  return (
    <Window
      title={title}
      theme={theme}
      width={610}
      height={640}
    >
      <Window.Content>
        <ByondUi
          params={{
            id: minimap_id,
            type: 'map',
          }}
          style={{
            width: "600px",
            height: "600px",
          }} />
      </Window.Content>
    </Window>
  );
};
