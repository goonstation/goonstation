import { BooleanLike } from 'common/react';
import { BoardPattern } from './Patterns';

export type BoardgameData = {
  boardInfo: {
    name: string;
    game: string;
    pattern: BoardPattern;
    startingPositions: { [key: string]: string };
    width: number;
    height: number;
    lock: boolean;
  };
  styling: {
    tileColour1: string;
    tileColour2: string;
    border: string;
    aspectRatio: number;
    useNotations: boolean;
  };
  board: string[];
  pieces: Piece[];

  users: User[];
  currentUser: User;
};

export type Piece = {
  code: string;
  x: number;
  y: number;
  prevX: number;
  prevY: number;
  selected: User;
  lastSelected: User;
  palette: string;
};

export type StartingPosition = {
  name: string;
  fen: string;
};

export type User = {
  ckey: string;
  name: string;
  mouseX: number;
  mouseY: number;
  selected?: Piece;
  palette?: string;
};

export type TileSize = {
  width: number;
  height: number;
};
