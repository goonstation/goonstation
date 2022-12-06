import { useBackend } from '../../../../../../backend';
import { useActions, useStates } from '../../../../utils/config';
import { BoardgameData } from '../../../../utils/types';
import GridGuideRenderer from '../../common/GridGuideRenderer';
import GridPieceRenderer from '../../common/GridPieceRenderer';
import { StyleProps } from '../types';
import CheckerBoardPattern from './CheckerBoardPattern';

export const CheckerBoard = ({ interactable }: StyleProps, context) => {
  const { act, data } = useBackend<BoardgameData>(context);
  const { pieces, currentUser } = data;
  const { tileSize, isFlipped, mouseCoords } = useStates(context);
  const { width, height } = tileSize;
  const { piecePlace, pieceRemove } = useActions(act);

  const boardPos = () => {
    const { x, y } = mouseCoords;
    const mx = x - 20;
    const my = y - 54;
    // alert(mx + ' ' + width);
    // alert(Math.floor(mx / width));

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

  const onSelectedPlace = () => {
    const [boardX, boardY] = boardPos();

    // Account for the fact that the backend
    // is a bit slow so we need to check if the
    // piece is held by the user before placing it

    /* let tries = 20; // 20 tries, 2 seconds max

    const waitForChange = () => {
      if (tries > 0) {
        piecePlace(currentUser.ckey, boardX, boardY);
        setTimeout(() => {
          if (!currentUser.selected) {
            waitForChange();
          } else {
            return; // Success
          }
        }, 100);
      }
      tries--;
    };
    waitForChange();*/
  };

  return (
    <div
      style={{
        position: 'relative',
        width: '100%',
        height: '100%',
      }}
      onMouseDown={(e) => {
        if (!interactable) return;
        if (e.button === 0) {
          // Used for placing pieces, click to select, click again to place handling
          if (currentUser.palette || currentUser.selected) {
            const [boardX, boardY] = boardPos();
            piecePlace(currentUser.ckey, boardX, boardY);
          }
        }
      }}
      onMouseUp={(e) => {
        if (!interactable) return;
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
      <GridPieceRenderer pieces={pieces} interactable />
    </div>
  );
};

export default CheckerBoard;
