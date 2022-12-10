export type BoardInfoType = {
  name: string;
  game: string;
  boardstyle: string;
  width: number;
  height: number;
  lock: boolean;
};

export type StylingType = {
  tileColor1: string;
  tileColor2: string;
  oldTileColor1: string;
  oldTileColor2: string;
  border: string;
  aspectRatio: number;
  useNotations: boolean;
  flipBoard: boolean;
};

export type BoardgameData = {
  boardInfo: BoardInfoType;
  styling: StylingType;
  board: string[];
  pieces: PieceDataType[];
  users: UserDataType[];
  currentUser: UserDataType;
  lastMovedPiece: string;
};

export type PieceDataType = {
  id: number;
  code: string;
  x: number;
  y: number;
  prevX: number;
  prevY: number;
  selected: string;
  lastSelected: string;
  palette: string;
};

export type UserDataType = {
  ckey: string;
  name: string;
  selected?: string;
  palette?: string;
};

export type TileSizeType = {
  width: number;
  height: number;
};

export type XYType = {
  x: number;
  y: number;
};
export type SizeType = {
  width: number;
  height: number;
};
