import { useBackend } from '../../../../../backend';
import { useStates } from '../../../utils/config';
import { BoardgameData } from '../../../utils/types';

/**
 * Renders help overlay for the board
 */

const GridGuideRenderer = (props, context) => {
  const { data } = useBackend<BoardgameData>(context);
  const { mouseCoords, tileSize } = useStates(context);
  const { width, height } = data.boardInfo;

  const mx = mouseCoords.x - 20;
  const my = mouseCoords.y - 54;

  const currentUser = data.currentUser;

  if (!currentUser) return null;
  if (!currentUser.selected) return null;

  const piece = data.pieces[currentUser.selected];
  if (!piece) return null;

  const px = piece.x * tileSize.width + tileSize.width / 2;
  const py = piece.y * tileSize.height + tileSize.height / 2;

  // Detect if the piece is to the left or right of the mouse
  // value is -tileSize.width if the piece is to the left of the mouse, if in between 0

  const graidentRotation = Math.atan2(py - my, px - mx) * (Math.PI / 180);

  // Mouse to grid
  const rectX = Math.floor(mx / tileSize.width) * tileSize.width;
  const rectY = Math.floor(my / tileSize.height) * tileSize.height;
  const rectWidth = tileSize.width;
  const rectHeight = tileSize.height;

  let rectCenterX = rectX + rectWidth / 2;
  let rectCenterY = rectY + rectHeight / 2;

  let xDiff = rectCenterX - px;
  let yDiff = rectCenterY - py;

  let distance = Math.sqrt(xDiff * xDiff + yDiff * yDiff);

  let xDiffNorm = xDiff / distance;
  let yDiffNorm = yDiff / distance;

  // x,y point, a bit away from the center of the tile, scale to winsize
  let arrowHeadPointX = rectCenterX - xDiffNorm * 40;
  let arrowHeadPointY = rectCenterY - yDiffNorm * 40;

  const showArrowX = distance > tileSize.width / 2;
  const showArrowY = distance > tileSize.height / 2;
  const showArrow = showArrowX && showArrowY;

  return (
    <svg
      style={{
        position: 'absolute',
        'pointer-events': 'none',
        top: 0,
        left: 0,
      }}
      width="100%"
      height="100%">
      <rect x={rectX} y={rectY} width={rectWidth} height={rectHeight} fill="red" fill-opacity="0.4" />
      <rect
        x={px - tileSize.width / 2}
        y={py - tileSize.height / 2}
        // Remove 10 from edge
        width={rectWidth}
        height={rectHeight}
        fill={showArrow ? 'red' : 'none'}
        fill-opacity="0.4"
      />
      {showArrow && (
        <defs>
          <marker
            id="arrow"
            markerWidth="10"
            markerHeight="10"
            refX="0"
            refY="3"
            orient="auto"
            markerUnits="strokeWidth">
            <path d="M0,0 L0,6 L9,3 z" fill="orange" stroke="none" />
          </marker>
        </defs>
      )}
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
          transform={`rotate(${graidentRotation} ${mx} ${my})`}
        />
      )}
    </svg>
  );
};

export default GridGuideRenderer;
