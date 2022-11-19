import { getPiecesByGame, PieceType } from '.';

export type PieceSet = {
  name: string;
  pieces: PieceType[];
};

export const sets: PieceSet[] = [];

sets.push({
  name: 'Chess',
  pieces: getPiecesByGame('chess'),
});

sets.push({
  name: 'Draughts',
  pieces: getPiecesByGame('draughts'),
});
