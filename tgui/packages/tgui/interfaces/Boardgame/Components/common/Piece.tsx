import { useBackend } from '../../../../backend';
import { BoardgameData } from '../../utils/types';
import { PieceSetupType } from '../../games';

export type PieceProps = {
  piece: PieceSetupType;
  isPresetPiece: boolean;
  position?: {
    x: number;
    y: number;
  };
};

/* export const getTwemojiSrc = (code: string) => {
  const image = twemoji.parse(code); // img as with src set to twemoji image
  // Get src from image
  // Example string: <img class="emoji" draggable="false" alt="😀" src="https://twemoji.maxcdn.com/v/14.0.2/72x72/1f600.png">
  let src = '';
  if (image.includes('src')) {
    src = image.split('src="')[1].split('"')[0];
  }
  return src;
};*/

type SvgFenRendererProps = {
  fenCode: string;
};

/**
 * USed for drawing the piece onto
 */
const SvgPieve = ({ fenCode }: SvgFenRendererProps) => {
  return (
    <svg viewBox="0 0 45 45" width="45" height="45">
      <text y="50%" x="50%" dy=".3em">
        {fenCode}
      </text>
    </svg>
  );
};

export const Piece = ({ piece, isPresetPiece, position }: PieceProps, context) => {
  const { act, data } = useBackend<BoardgameData>(context);
  const { image } = piece;
  return <img src={image} />;

  /* return (
    <Box className={`boardgame__piece`}>
      <img src={image} />
    </Box>
  );*/

  return;
};
