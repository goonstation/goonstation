declare const Byond, window;

import { useBackend } from '../../../backend';
import { useActions, useStates } from './config';
import { BoardgameData } from './types';

export const adjustSizes = (context) => {
  adjustTileSize(context);
  adjustWindowSize(context);
};

const adjustTileSize = (context) => {
  const { data } = useBackend<BoardgameData>(context);
  const { setTileSize, tileSize } = useStates(context);

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
    setTileSize({ width: tileWidth, height: tileHeight });
  }
};

const adjustWindowSize = (context) => {
  const { data } = useBackend<BoardgameData>(context);
  const { aspectRatio } = data.styling;

  const PaletteSetPadding = 100; // Add 100 pixels to the width
  const titlebarHeightPadding = 32;
  let width = 500;
  let height = 400;
  // Fetch boardgame__wrapper element and get its width and height
  const wrapper = document.getElementsByClassName('boardgame__window')[0];
  if (wrapper) {
    const wrapperRect = wrapper.getBoundingClientRect();
    let wrapperWidth = wrapperRect.width;
    let wrapperHeight = wrapperRect.height;

    // Return if the width and height are the same
    if (wrapperWidth === width && wrapperHeight === height) {
      return;
    }

    let shortestSide = wrapperWidth < wrapperHeight ? wrapperWidth : wrapperHeight;

    // Set the width and height to the shortest side
    width = shortestSide + PaletteSetPadding;
    height = shortestSide + titlebarHeightPadding;

    // Set the width and height to the aspect ratio
    if (aspectRatio) {
      width = shortestSide * aspectRatio + PaletteSetPadding;
      height = shortestSide + titlebarHeightPadding;
    }
  }

  Byond.winset(window.__windowId__, {
    size: `${width}x${height}`,
  });
};

export const handleEvents = (context) => {
  const { act, data } = useBackend<BoardgameData>(context);
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
