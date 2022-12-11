import { Box } from '../../../../components';
import { BoardgameData } from '../../utils';
import { useBackend } from '../../../../backend';
import { useStates } from '../../utils';
import { codeRecordFromPieces, fetchPieces } from '../../games';

export const HeldPieceRenderer = (_, context) => {
  const { act, data } = useBackend<BoardgameData>(context);

  if (!data.currentUser) return null;

  const { mouseCoords, paletteLastElement } = useStates(context);
  const { x, y } = mouseCoords;

  let code = null;
  if (data.currentUser.palette) {
    code = data.currentUser.palette;
  } else if (data.currentUser.selected) {
    code = data.currentUser.selected;
  }

  if (!code) return null;

  const pieces = fetchPieces();
  const piece = codeRecordFromPieces(pieces)[code];

  if (!piece) return null;

  return (
    <Box
      className={`boardgame__heldpiece`}
      style={{
        'top': y + 'px',
        'left': x + 'px',
        width: '120px',
        height: '120px',
      }}>
      <Box className="boardgame__heldpiece-inner">
        <img src={piece.image} />
      </Box>
      <Box
        style={{
          'font-size': '12px',
          'font-weight': 'bold',
          'text-shadow': '0 0 2px black',
        }}>
        Right click to cancel
      </Box>
    </Box>
  );
};
