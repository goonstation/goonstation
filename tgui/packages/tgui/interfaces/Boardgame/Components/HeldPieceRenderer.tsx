declare const React;

import { fenCodeRecordFromPieces, fetchPieces, PieceType } from '../Pieces';
import { Box } from '../../../components';
import { BoardgameData } from '../types';
import { useBackend, useLocalState } from '../../../backend';

export const HeldPieceRenderer = (_, context) => {
  const { act, data } = useBackend<BoardgameData>(context);
  const { currentUser } = data;

  const [mouseCoords, setMouseCoords] = useLocalState<{
    x: number;
    y: number;
  }>(context, 'mouseCoords', { x: 0, y: 0 });

  const code = currentUser?.palette || currentUser.selected?.code;

  if (code) {
    const pieces = fetchPieces();
    const piece: PieceType = fenCodeRecordFromPieces(pieces)[code];

    // Draw the piece with svg fixed to the mouse

    return (
      <Box
        className="boardgame__heldpiece"
        style={{
          top: mouseCoords.y + 'px',
          left: mouseCoords.x + 'px',
          width: '30px',
          height: '30px',
        }}>
        <img src={piece?.image} />
        <span>{piece?.name}</span>
      </Box>
    );
  } else {
    return null;
  }
};
