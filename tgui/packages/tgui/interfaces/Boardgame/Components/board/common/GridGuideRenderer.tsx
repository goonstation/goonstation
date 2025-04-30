import { useBackend } from '../../../../../backend';
import { useStates } from '../../../utils';
import { BoardgameData } from '../../../utils';

/**
 * Renders help overlay for the board
 */

const GridGuideRenderer = () => {
  const { data } = useBackend<BoardgameData>();
  const { mouseCoords, tileSize, isFlipped } = useStates();
  const { width, height } = data.boardInfo;

  const currentUser = data.currentUser;
  if (!currentUser || !currentUser.selected) return null;

  const piece = data.pieces[currentUser.selected];
  if (!piece) return null;

  let px = piece.x * tileSize.width + tileSize.width / 2;
  let py = piece.y * tileSize.height + tileSize.height / 2;

  const mx = mouseCoords.x - 20;
  const my = mouseCoords.y - 54;

  const rectX = Math.floor(mx / tileSize.width) * tileSize.width;
  const rectY = Math.floor(my / tileSize.height) * tileSize.height;
  const rectCenterX = rectX + tileSize.width / 2;
  const rectCenterY = rectY + tileSize.height / 2;

  const xDiff = rectCenterX - px;
  const yDiff = rectCenterY - py;
  const distance = Math.sqrt(xDiff * xDiff + yDiff * yDiff);

  const showArrow =
    distance > tileSize.width / 2 && distance > tileSize.height / 2;

  const xDiffNorm = xDiff / distance;
  const yDiffNorm = yDiff / distance;

  const arrowHeadPointX = rectCenterX - xDiffNorm * 40;
  const arrowHeadPointY = rectCenterY - yDiffNorm * 40;

  return (
    <svg className={'boardgame__board-ggrenderer'} width="100%" height="100%">
      <rect
        x={rectX}
        y={rectY}
        width={tileSize.width}
        height={tileSize.height}
        fill="red"
        fill-opacity="0.4"
      />
      <rect
        x={
          isFlipped
            ? width * tileSize.width - px - tileSize.width / 2
            : px - tileSize.width / 2
        }
        y={
          isFlipped
            ? height * tileSize.height - py - tileSize.height / 2
            : py - tileSize.height / 2
        }
        // Remove 10 from edge
        width={tileSize.width}
        height={tileSize.height}
        fill={showArrow ? 'red' : 'none'}
        fill-opacity="0.4"
      />
      {showArrow && <ArrowHead />}
      {showArrow && (
        <line
          x1={px}
          y1={py}
          x2={arrowHeadPointX}
          y2={arrowHeadPointY}
          stroke="orange"
          fill="none"
          stroke-width="3"
          marker-end="url(#arrow)"
        />
      )}
    </svg>
  );
};

const ArrowHead = () => (
  <defs>
    <marker
      id="arrow"
      markerWidth="10"
      markerHeight="10"
      refX="0"
      refY="3"
      orient="auto"
      markerUnits="strokeWidth"
    >
      <path d="M0,0 L0,6 L9,3 z" fill="orange" stroke="none" />
    </marker>
  </defs>
);

export default GridGuideRenderer;
