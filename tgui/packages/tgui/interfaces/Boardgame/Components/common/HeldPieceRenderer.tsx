import { Box } from 'tgui-core/components';

import { useBackend } from '../../../../backend';
import { codeRecordFromPieces, fetchPieces } from '../../games';
import { BoardgameData } from '../../utils';
import { useStates } from '../../utils';

export const HeldPieceRenderer = () => {
  const { data } = useBackend<BoardgameData>();

  // Exit early if there is no current user
  if (!data.currentUser) return null;

  const { mouseCoords } = useStates();
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
        top: y + 'px',
        left: x + 'px',
        width: '120px',
        height: '120px',
      }}
    >
      <Box className="boardgame__heldpiece-inner">
        <img src={piece.image} />
      </Box>
      <Box
        style={{
          fontSize: '12px',
          fontWeight: 'bold',
          textShadow: '0 0 2px black',
        }}
      >
        Right click to cancel
      </Box>
    </Box>
  );
};
