import { useBackend } from '../../../../../../backend';
import { BoardgameData } from '../../../../utils';

const CheckerBoardPattern = (props, context) => {
  const { data, act } = useBackend<BoardgameData>(context);
  const { tileColor1, tileColor2 } = data.styling;

  const width = 100 / data.boardInfo.width;
  const height = 100 / data.boardInfo.height;

  return (
    <svg width="100%" height="100%">
      <pattern id="pattern" x="0" y="0" width={width * 2 + '%'} height={height * 2 + '%'} patternUnits="userSpaceOnUse">
        <rect width={width + '%'} height={height + '%'} fill={tileColor1} />
        <rect x={width + '%'} y={height + '%'} width={width + '%'} height={height + '%'} fill={tileColor1} />
        <rect x={width + '%'} width={width + '%'} height={height + '%'} fill={tileColor2} />
        <rect y={height + '%'} width={width + '%'} height={height + '%'} fill={tileColor2} />
      </pattern>
      <rect width="100%" height="100%" fill="url(#pattern)" />
    </svg>
  );
};

export default CheckerBoardPattern;
