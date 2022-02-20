import { useBackend, useLocalState } from '../backend';
import { Button, ByondUi } from '../components';
import { Window } from '../layouts';

export const AIMap = (params, context) => {
  return (
    <Window
      width={600}
      height={600}
    >
      <Window.Content>
        <ByondUi
          params={{
            type: 'map',
            id: "ai_map",
          }}
          style={{
            width: "600px",
            height: "600px",
          }} />
      </Window.Content>
    </Window>
  );
};
