import { useBackend } from '../../../../../backend';
import { codeRecordFromPieces, fetchPieces } from '../../../games';
import { useActions, useStates } from '../../../utils';
import { BoardgameData, PieceDataType } from '../../../utils';
import { Box } from '../../../../../components';

type GridPieceRendererProps = {
  pieces: PieceDataType[];
  interactable: boolean; // Used for previewing pieces, not for actual gameplay
};

const GridPieceRenderer = ({ pieces, interactable }: GridPieceRendererProps, context) => {
  const { act, data } = useBackend<BoardgameData>(context);

  const { currentUser, lastMovedPiece } = data;
  const { isFlipped, tileSize } = useStates(context);
  const { pieceSelect, pieceRemove, piecePlace } = useActions(act);
  const { width, height } = data.boardInfo;

  const pieceRecords = codeRecordFromPieces(fetchPieces());

  // Draw the pieces
  // Offset by 20px to left and top
  return (
    <Box>
      {Object.keys(pieces).map((val, index) => {
        const { x, y, prevX, prevY, code, selected } = pieces[val];
        const pieceType = pieceRecords[code];

        // Is the piece selected by currentUser?
        const pieceSelectedByUser = selected && currentUser !== selected;

        let left = x * tileSize.width;
        let top = y * tileSize.height;

        if (isFlipped) {
          // 1 is subtracted from the x and y values to account for the fact that
          // the board is 0 indexed, but the width and height are not.
          // aka 1-width, 1-height, not 0-width, 0-height
          left = (width - x - 1) * tileSize.width;
          top = (height - y - 1) * tileSize.height;
        }

        return (
          <div
            onmousedown={(e) => {
              if (!interactable) return;
              if (e.button === 0 && !selected) {
                if (currentUser.palette) {
                  piecePlace(currentUser.ckey, x, y);
                }

                if (currentUser.selected && !pieceSelectedByUser) {
                  piecePlace(currentUser.ckey, x, y);
                }

                if (!currentUser.selected) {
                  pieceSelect(currentUser.ckey, val);
                }
              }
              if (e.button === 2) {
                if (!selected) {
                  pieceRemove(val);
                }
              }
            }}
            onmouseup={(e) => {
              if (!interactable) return;
              if (currentUser.palette) {
                piecePlace(currentUser.ckey, x, y);
              }
              if (currentUser.selected && !pieceSelectedByUser) {
                piecePlace(currentUser.ckey, x, y);
              }
            }}
            style={{
              position: 'absolute',
              left: left + 'px',
              top: top + 'px',
              width: tileSize.width + 'px',
              height: tileSize.height + 'px',
            }}
            key={index}>
            <img
              style={{
                width: tileSize.width + 'px',
                height: tileSize.width + 'px',
              }}
              src={pieceType.image}
            />
            <span
              // Center text bellow img
              style={{
                'position': 'absolute',
                'left': '50%',
                'top': '50%',
                'transform': 'translate(-50%, -50%)',
                'font-size': '14px',
                'font-weight': 'bolder',
                'text-shadow': '0 0 2px black',
                'z-index': 1,
                'font-family': 'Arial',
              }}>
              {selected}
            </span>
          </div>
        );
      })}
    </Box>
  );
};

export default GridPieceRenderer;
