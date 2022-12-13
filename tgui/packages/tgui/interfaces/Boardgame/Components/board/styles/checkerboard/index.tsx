import { createRef } from 'inferno';
import { useBackend } from '../../../../../../backend';
import { useActions, useStates } from '../../../../utils';
import { BoardgameData } from '../../../../utils';
import GridGuideRenderer from '../../common/GridGuideRenderer';
import GridPieceRenderer from '../../common/GridPieceRenderer';
import CheckerBoardPattern from './CheckerBoardPattern';

export const CheckerBoard = (props, context) => {
  const { act, data } = useBackend<BoardgameData>(context);
  const { pieces, currentUser } = data;
  const { tileColor2 } = data.styling;
  const { tileSize, isFlipped, mouseCoords } = useStates(context);
  const { width, height } = tileSize;
  const { piecePlace } = useActions(act);

  const boardRef = createRef<HTMLDivElement>();

  const boardPos = () => {
    const { x, y } = mouseCoords;

    // Out of bounds cancels the placement
    if (!boardRef) return [-1, -1];

    const rect = boardRef.current.getBoundingClientRect();

    const mx = x - rect.left;
    const my = y - rect.top;

    let boardX = Math.floor(mx / width);
    let boardY = Math.floor(my / height);

    if (isFlipped) {
      // 1 is subtracted from the x and y values to account for the fact that
      // the board is 0 indexed, but the width and height are not.
      // aka 1-width, 1-height, not 0-width, 0-height
      boardX = data.boardInfo.width - boardX - 1;
      boardY = data.boardInfo.height - boardY - 1;
    }

    return [boardX, boardY];
  };

  return (
    <div
      style={{
        'background-color': tileColor2,
      }}
      ref={boardRef}
      className="boardgame__board-checkerboard"
      onMouseDown={(e) => {
        if (e.button === 0) {
          // Used for placing pieces, click to select, click again to place handling
          if (currentUser.palette || currentUser.selected) {
            const [boardX, boardY] = boardPos();
            piecePlace(currentUser.ckey, boardX, boardY);
          }
        }
      }}
      onMouseUp={(e) => {
        if (e.button === 0) {
          // Used for placing pieces, drag and drop handling
          const [boardX, boardY] = boardPos();

          if (currentUser.palette) {
            piecePlace(currentUser.ckey, boardX, boardY);
            return;
          }
          if (currentUser.selected) {
            const piece = pieces[currentUser.selected];
            if (piece.x !== boardX || piece.y !== boardY) {
              piecePlace(currentUser.ckey, boardX, boardY);
            }
            // Check if the position is same as the piece's current position, if it's not, place it
          }
        }
      }}>
      <CheckerBoardPattern />
      <GridGuideRenderer />
      <GridPieceRenderer pieces={pieces} />
    </div>
  );
};

export default CheckerBoard;
