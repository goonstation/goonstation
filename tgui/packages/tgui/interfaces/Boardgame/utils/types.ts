export type BoardInfo = {
  name: string;
  game: string;
  boardstyle: string;
  width: number;
  height: number;
  lock: boolean;
};

export type Styling = {
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
  boardInfo: BoardInfo;
  styling: Styling;
  board: string[];
  pieces: PieceData[];
  users: UserData[];
  currentUser: UserData;
  lastMovedPiece: string;
};

export type PieceData = {
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

export type UserData = {
  ckey: string;
  name: string;
  selected?: string;
  palette?: string;
};

export type TileSizeData = {
  width: number;
  height: number;
};
