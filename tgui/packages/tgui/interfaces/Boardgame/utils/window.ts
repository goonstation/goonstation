declare const Byond, window;

import { BoardInfoType, TileSizeType, UserDataType } from './types';

export const adjustSizes = (
  boardInfo: BoardInfoType | undefined,
  tileSize: TileSizeType,
  setTileSizeType: (size: TileSizeType) => void,
) => {
  adjustTileSizeType(boardInfo, tileSize, setTileSizeType);
  adjustWindowSize();
};

const adjustTileSizeType = (
  boardInfo: BoardInfoType | undefined,
  tileSize: TileSizeType,
  setTileSizeType: (size: TileSizeType) => void,
) => {
  const board = document.getElementsByClassName('boardgame__board-inner')[0];
  let tileWidth: number = 0;
  let tileHeight: number = 0;

  if (board && boardInfo) {
    const boardRect = board.getBoundingClientRect();

    const boardWidth = boardRect.width - 40; // Full width of the board
    const boardHeight = boardRect.height - 40; // Full height of the board

    tileWidth = boardWidth / boardInfo.width; // Width of a single tile
    tileHeight = boardHeight / boardInfo.height; // Height of a single tile
  }

  // Compare old tile size to new tile size
  if (tileWidth !== tileSize.width || tileHeight !== tileSize.height) {
    setTileSizeType({ width: tileWidth, height: tileHeight });
  }
};

// This used to contain a bunch of brittle code to handle different window sizes
// That broke everything so we're just hard setting it to the right size for now
const adjustWindowSize = () => {
  let width = 580;
  let height = 512;
  Byond.winset(window.__windowId__, {
    size: `${width}x${height}`,
  });
};

export const handleEvents = (
  currentUser: UserDataType | undefined,
  paletteClear: (ckey: string) => void,
  pieceDeselect: (ckey: string) => void,
) => {
  document.body.oncontextmenu = (e) => {
    e.preventDefault();
    if (e.button === 2) {
      if (currentUser?.palette) {
        paletteClear(currentUser.ckey);
      }
      if (currentUser?.selected) {
        pieceDeselect(currentUser.ckey);
      }
    }
    return false;
  };

  document.body.onmouseleave = () => {
    if (currentUser?.palette) {
      paletteClear(currentUser.ckey);
    }
  };
};
