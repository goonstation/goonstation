import { Board } from '../board';
import { Window } from '../../../../layouts';
import { Palettes } from '../';
import { useStates } from '../../utils';

export const BoardgameContents = (props, context) => {
  const { mouseCoordsSet } = useStates(context);

  return (
    <Window.Content
      onMouseMove={(e) => {
        mouseCoordsSet({
          x: e.clientX,
          y: e.clientY,
        });
      }}
      fitted
      className="boardgame__window">
      <Board />
      <Palettes />
    </Window.Content>
  );
};
