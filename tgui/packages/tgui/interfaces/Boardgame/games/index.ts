import { GameName, kits } from './kits';

export type GameKit = {
  pieces: PieceSetupType[];
  // Palette drawer groups
  palettes: PaletteSet[];
};

/**
 * Pieces
 */

export type PieceSetupType = {
  code: string;
  name: string;
  game: GameName;
  image?: string;
};

const pieces: PieceSetupType[] = [];

// Push gamekit pieces into pieces array
kits.forEach((kit: GameKit) => {
  pieces.push(...kit.pieces);
});

export const pushPieces = (newPieces: PieceSetupType[]) => {
  return pieces.push(...newPieces);
};

export const getPiece = (fenCode: string, game: string) => {
  return pieces.find((piece) => piece.code === fenCode && piece.game === game);
};

export const getPiecesByGame = (game: string): PieceSetupType[] => {
  return pieces.filter((piece) => piece.game === game);
};

export const codeRecordFromPieces = (
  pieces: PieceSetupType[],
): Record<string, PieceSetupType> => {
  return pieces.reduce((map, piece) => {
    map[piece.code] = piece;
    return map;
  }, {});
};

export const fetchPieces = () => pieces;

/**
 * Sets
 */

export type PaletteSet = {
  name: string;
  pieces: PieceSetupType[];
};

export const palettes: PaletteSet[] = [];

// Push gamekit presets into pieces array
kits.forEach((kit: GameKit) => {
  palettes.push(...kit.palettes);
});

export const fetchPalettes = () => palettes;
