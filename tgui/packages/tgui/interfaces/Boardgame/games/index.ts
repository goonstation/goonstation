import { GameName, kits } from './kits';

export type GameKit = {
  pieces: PieceSetupType[];
  presets: PresetType[];
  // Palette drawer groups
  palettes: PaletteSet[];
  facts?: string[];
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

export const fenCodeRecordFromPieces = (pieces: PieceSetupType[]): Record<string, PieceSetupType> => {
  return pieces.reduce((map, piece) => {
    map[piece.code] = piece;
    return map;
  }, {});
};

export const fetchPieces = () => pieces;

/*
 * Presets
 */

export type PresetType = {
  name: string;
  game: GameName;
  description: string;
  rules?: JSX.Element;
  // string or function that returns string
  setup: string | (() => string);
  boardWidth: number;
  boardHeight: number;
  kit?: GameKit; // Set when added to the game
  wikiPage?: string; // Wiki page for the game from https://wiki.ss13.co/
};

export const presets: PresetType[] = [];

// Push gamekit presets into pieces array
kits.forEach((kit: GameKit) => {
  presets.push(...kit.presets.map((preset) => ({ ...preset, kit })));
});

export const pushPresets = (newPresets: PresetType[]) => {
  return presets.push(...newPresets);
};

export const getPresetsBySize = (width: number, height: number): PresetType[] => {
  return presets.filter((preset) => preset.boardWidth === width && preset.boardHeight === height);
};

// Create record of all the presets, indexed by game
export const presetsByGame = () => {
  const record: Record<string, PresetType[]> = {};
  presets.forEach((preset) => {
    if (!record[preset.game]) {
      record[preset.game] = [];
    }
    record[preset.game].push(preset);
  });
  return record;
};

export const fetchPresets = () => presets;

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
