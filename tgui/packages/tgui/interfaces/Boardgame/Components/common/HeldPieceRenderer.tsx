import { Box } from '../../../../components';
import { BoardgameData } from '../../utils';
import { useBackend } from '../../../../backend';
import { useStates } from '../../utils';
import { codeRecordFromPieces, fetchPieces } from '../../games';

export const HeldPieceRenderer = (_, context) => {
  const { act, data } = useBackend<BoardgameData>(context);

  // Exit early if there is no current user
  if (!data.currentUser) return null;

  const { mouseCoords } = useStates(context);
  const { x, y } = mouseCoords;

  // Get the piece code
  const code = data.currentUser.palette || data.currentUser.selected;

  // Exit early if no piece code was found
  if (!code) return null;

  // Get the piece record from the code
  const pieces = fetchPieces();
  const piece = codeRecordFromPieces(pieces)[code];

  // Exit early if no piece record was found
  if (!piece) return null;

  // Render the piece
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
