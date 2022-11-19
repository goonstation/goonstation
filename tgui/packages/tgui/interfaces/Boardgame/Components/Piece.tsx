declare const React;
declare const twemoji;

import { Box } from '../../../components';
import { classes } from 'common/react';
import { useBackend, useLocalState } from '../../../backend';
import { TileSize, BoardgameData, User, StartingPosition } from '../types';
import { PieceType } from '../Pieces';

export type PieceProps = {
  piece: PieceType;
  isSetPiece: boolean;
  position?: {
    x: number;
    y: number;
  };
};

export const getTwemojiSrc = (code: string) => {
  const image = twemoji.parse(code); // img as with src set to twemoji image
  // Get src from image
  // Example string: <img class="emoji" draggable="false" alt="😀" src="https://twemoji.maxcdn.com/v/14.0.2/72x72/1f600.png">
  let src = '';
  if (image.includes('src')) {
    src = image.split('src="')[1].split('"')[0];
  }
  return src;
};

export const Piece = ({ piece, isSetPiece, position }: PieceProps, context) => {
  const { act, data } = useBackend<BoardgameData>(context);
  const { currentUser, pieces } = data;
  const { fenCode, name, game, image } = piece;
  const { x, y } = position || { x: -1, y: -1 }; // Default to 0,0 if no position is provided

  return <Box className={`boardgame__piece`}>{image ? <img src={image} /> : <img src={getTwemojiSrc(fenCode)} />}</Box>;
};

type SvgFenRendererProps = {
  fenCode: string;
};

const SvgFenRenderer = ({ fenCode }: SvgFenRendererProps) => {
  return (
    <svg viewBox="0 0 45 45" width="45" height="45">
      <text y="50%" x="50%" dy=".3em">
        {fenCode}
      </text>
    </svg>
  );
};
