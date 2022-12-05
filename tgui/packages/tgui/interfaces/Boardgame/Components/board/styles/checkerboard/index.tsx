import { useBackend } from '../../../../../../backend';
import { useActions, useStates } from '../../../../utils/config';
import { BoardgameData } from '../../../../utils/types';
import GridGuideRenderer from '../../common/GridGuideRenderer';
import GridPieceRenderer from '../../common/GridPieceRenderer';
import CheckerBoardPattern from './CheckerBoardPattern';

export const CheckerBoard = (props, context) => {
  const { act, data } = useBackend<BoardgameData>(context);
  const { pieces, currentUser } = data;
  const { tileSize, isFlipped, mouseCoords } = useStates(context);
  const { width, height } = tileSize;
  const { piecePlace, pieceRemove } = useActions(act);

  const boardPos = (e) => {
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

  const onPlace = (e) => {
    const [boardX, boardY] = boardPos(e);

    if (currentUser.palette) {
      piecePlace(currentUser.ckey, boardX, boardY);
      return;
    }

    // Account for the fact that the backend
    // is a bit slow so we need to check if the
    // piece is held by the user before placing it
    let tries = 10; // 10 tries, 1 second max

    const waitForChange = () => {
      if (tries > 0) {
        setTimeout(() => {
          if (!currentUser.selected) {
            waitForChange();
          } else {
            piecePlace(currentUser.ckey, boardX, boardY);
          }
        }, 100);
      }
      tries--;
    };
    waitForChange();
  };

  return (
    <div
      style={{
        position: 'relative',
        width: '100%',
        height: '100%',
      }}
      onMouseDown={(e) => {
        if (e.button === 0) {
          if (currentUser.palette || currentUser.selected) {
            onPlace(e);
          }
        }
      }}
      onMouseUp={(e) => {
        if (e.button === 0) {
          if (currentUser.palette) {
            onPlace(e);
          }
          if (currentUser.selected) {
            const [boardX, boardY] = boardPos(e);
            const piece = pieces[currentUser.selected];
            // alert(piece.x + ' ' + piece.y + ' ' + boardX + ' ' + boardY);
            if (piece.x !== boardX && piece.y !== boardY) {
              onPlace(e);
            }
          }
        }
      }}
      onDblClick={(e) => {
        if (currentUser.selected) {
        }
      }}>
      <CheckerBoardPattern />
      <GridGuideRenderer />
      <GridPieceRenderer pieces={pieces} />
    </div>
  );
};

export default CheckerBoard;
