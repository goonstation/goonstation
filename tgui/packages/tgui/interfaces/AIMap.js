import { useBackend, useLocalState } from '../backend';
import { Button, ByondUi } from '../components';
import { Window } from '../layouts';

export const AIMap = (props, context) => {
  return (
    <Window>
      <Window.Content>
        <ByondUi
          params={{
            type: 'button',
            text: 'Hello world',
          }} />
        <ByondUi
          params={{
            type: 'map',
            id: "mapwindow.map",
            zoom: '2',
            pos: "144,84",
          }} />
      </Window.Content>
    </Window>
  );
};
