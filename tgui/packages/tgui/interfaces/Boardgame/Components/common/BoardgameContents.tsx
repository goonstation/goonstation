import { Window } from '../../../../layouts';
import { useStates } from '../../utils';
import { Palettes } from '../';
import { Board } from '../board';

export const BoardgameContents = () => {
  const { mouseCoordsSet } = useStates();

  return (
    <Window.Content
      onMouseMove={(e) => {
        mouseCoordsSet({
          x: e.clientX,
          y: e.clientY,
        });
      }}
      fitted
      className="boardgame__window"
    >
      <Board />
      <Palettes />
    </Window.Content>
  );
};
