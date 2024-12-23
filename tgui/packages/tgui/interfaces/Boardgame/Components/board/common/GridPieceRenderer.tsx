import { Box } from 'tgui-core/components';

import { useBackend } from '../../../../../backend';
import { codeRecordFromPieces, fetchPieces } from '../../../games';
import { useActions, useStates } from '../../../utils';
import { BoardgameData, PieceDataType } from '../../../utils';

type GridPieceRendererProps = {
  pieces: PieceDataType[];
};

const GridPieceRenderer = ({ pieces }: GridPieceRendererProps) => {
  const { act, data } = useBackend<BoardgameData>();

  const { currentUser, users } = data;
  const { isFlipped, tileSize } = useStates();
  const { pieceSelect, pieceRemove, piecePlace } = useActions(act);
  const { width, height } = data.boardInfo;

  const pieceRecords = codeRecordFromPieces(fetchPieces());

  // Draw the pieces
  // Offset by 20px to left and top
  return (
    <Box className="boardgame__board-gprenderer">
      {Object.keys(pieces).map((val, index) => {
        const { x, y, code, selected } = pieces[val];
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

        const selectedName = users[selected]?.name || '';

        return (
          <div
            className="boardgame__board-gprenderer-piece"
            onMouseDown={(e) => {
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
            onMouseUp={(e) => {
              if (currentUser.palette) {
                piecePlace(currentUser.ckey, x, y);
              }
              if (currentUser.selected && !pieceSelectedByUser) {
                piecePlace(currentUser.ckey, x, y);
              }
            }}
            style={{
              left: left + 'px',
              top: top + 'px',
              width: tileSize.width + 'px',
              height: tileSize.height + 'px',
            }}
            key={index}
          >
            <img
              style={{
                width: tileSize.width + 'px',
                height: tileSize.width + 'px',
              }}
              src={pieceType.image}
            />
            {selected && <span>{selectedName}</span>}
          </div>
        );
      })}
    </Box>
  );
};

export default GridPieceRenderer;
