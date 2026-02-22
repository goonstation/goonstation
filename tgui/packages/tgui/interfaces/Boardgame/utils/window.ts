declare const Byond, window;

import { useBackend } from '../../../backend';
import { useActions, useStates } from '.';
import { BoardgameData } from './types';

export const adjustSizes = () => {
  adjustTileSizeType();
  adjustWindowSize();
};

const adjustTileSizeType = () => {
  const { data } = useBackend<BoardgameData>();
  const { setTileSizeType, tileSize } = useStates();

  const board = document.getElementsByClassName('boardgame__board-inner')[0];
  let tileWidth: number = 0;
  let tileHeight: number = 0;

  if (board) {
    const boardRect = board.getBoundingClientRect();

    const boardWidth = boardRect.width - 40; // Full width of the board
    const boardHeight = boardRect.height - 40; // Full height of the board

    tileWidth = boardWidth / data.boardInfo.width; // Width of a single tile
    tileHeight = boardHeight / data.boardInfo.height; // Height of a single tile
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

export const handleEvents = () => {
  const { act, data } = useBackend<BoardgameData>();
  const { paletteClear, pieceDeselect } = useActions(act);

  document.body.oncontextmenu = (e) => {
    e.preventDefault();
    if (e.button === 2) {
      if (data.currentUser?.palette) {
        paletteClear(data.currentUser.ckey);
      }
      if (data.currentUser?.selected) {
        pieceDeselect(data.currentUser.ckey);
      }
    }
    return false;
  };

  document.body.onmouseleave = () => {
    if (data.currentUser?.palette) {
      paletteClear(data.currentUser.ckey);
    }
  };
};
