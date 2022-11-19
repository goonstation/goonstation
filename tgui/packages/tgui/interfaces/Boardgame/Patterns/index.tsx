declare const React;

import { flip } from '@popperjs/core';
import { useBackend, useLocalState } from '../../../backend';
import { fenCodeRecordFromPieces, fetchPieces, PieceType } from '../Pieces';
import { BoardgameData } from '../types';
import { CheckerBoard } from './checkerboard';

export type BoardPattern = 'checkerboard' | 'hexagon' | 'go';

type PatternProps = {
  pattern: BoardPattern;
};

type PatternToUseProps = {
  pattern: string;
};

const PatternToUse = ({ pattern }: PatternToUseProps, context) => {
  return <CheckerBoard />;
};

export const Pattern = ({ pattern }: PatternProps, context) => {
  const { act, data } = useBackend<BoardgameData>(context);

  const { pieces, currentUser } = data;
  const pieceRecords = fenCodeRecordFromPieces(fetchPieces());

  const [flip] = useLocalState(context, 'flip', false);

  const [, setTranslateCoords] = useLocalState<{
    x: number;
    y: number;
  }>(context, 'translateCoords', { x: 0, y: 0 });

  const [mouseCoords] = useLocalState<{
    x: number;
    y: number;
  }>(context, 'mouseCoords', { x: 0, y: 0 });
  const [, setTileSize] = useLocalState(context, 'tileSize', {
    width: 50,
    height: 50,
  });
  let { x, y } = mouseCoords;

  const board = document.getElementsByClassName('boardgame__board-inner')[0];
  let tileWidth: number = 0,
    tileHeight: number = 0;
  if (board) {
    const boardRect = board.getBoundingClientRect();

    const boardWidth = boardRect.width - 40; // Full width of the board
    const boardHeight = boardRect.height - 40; // Full height of the board

    tileWidth = boardWidth / data.boardInfo.width; // Width of a single tile
    tileHeight = boardHeight / data.boardInfo.height; // Height of a single tile
  }

  let patternMulti = 1; // Divide by this to get the board coord

  let boardX = Math.floor(((x - 20) / tileWidth) * patternMulti);
  let boardY = Math.floor(((y - 52) / tileHeight) * patternMulti);

  // reverse the y axis if the board is flipped
  if (flip) {
    boardY = data.boardInfo.height - boardY - 1;
  }

  // Round the board coords to the nearest integer
  // if lock is true, round to the nearest integer

  return (
    <svg
      overflow="visible"
      className={`boardgame__pattern ${flip ? 'boardgame__patternflip' : ''}`}
      onmousemove={(e) => {
        setTileSize({ width: tileWidth, height: tileHeight });
        let x = flip ? data.boardInfo.width - boardX - 1 : boardX;
        setTranslateCoords({
          x: x,
          y: boardY,
        });
      }}
      onmousedown={(e) => {}}
      onmouseup={(e) => {
        // Convert the mouse coords to board coords
        // If the board is 8 tiles wide, and the mouse is at 50% of the board width, the board coord is 4
        // Use x,y, boardWidth, boardHeight, tileWidth, tileHeight only, boardRect.x and boardRect.y are not needed

        let x = flip ? data.boardInfo.width - boardX - 1 : boardX;

        act('pawnPlace', {
          ckey: currentUser.ckey,
          x: x,
          y: boardY,
        });
      }}
      width="100%"
      height="100%">
      <PatternToUse pattern={pattern} />
      <PiecesSvgRenderer pieceRecords={pieceRecords} />
      <OverlaySvg pieceRecords={pieceRecords} />
    </svg>
  );
};

type OverlaySvgRendererProps = {
  pieceRecords: Record<string, PieceType>;
};

// Draw names of player moving the pieces, lines between moved pieces and the piece being moved
const OverlaySvg = ({ pieceRecords }: OverlaySvgRendererProps, context) => {
  const { act, data } = useBackend<BoardgameData>(context);
  const [flip] = useLocalState(context, 'flip', false);
  const { pieces, currentUser } = data;
  const { lock } = data.boardInfo;

  const { tileColour1, tileColour2 } = data.styling;
  const width = 100 / data.boardInfo.width;
  const height = 100 / data.boardInfo.height;
  const board = document.getElementsByClassName('boardgame__board-inner')[0];
  let tileWidth: number = 0,
    tileHeight: number = 0;
  if (board) {
    const boardRect = board.getBoundingClientRect();

    const boardWidth = boardRect.width - 40; // Full width of the board
    const boardHeight = boardRect.height - 40; // Full height of the board

    tileWidth = boardWidth / data.boardInfo.width; // Width of a single tile
    tileHeight = boardHeight / data.boardInfo.height; // Height of a single tile
  }
  return (
    <svg width="100%" height="100%" overflow="visible">
      {Object.keys(pieces).map((val, index) => {
        const { x, y, prevX, prevY, code } = pieces[val];
        const selected = pieces[val].selected;
        const pieceType = pieceRecords[code];

        const name = selected?.name || '';
        const firstName = name.split(' ')[0];
        const lastName = name.split(' ')[1];
        const lastNamefirstLetter = lastName?.charAt(0) || '';

        return (
          <svg
            overflow="visible"
            key={index}
            x={width * x + '%'}
            y={height * y + '%'}
            width={width + '%'}
            height={height + '%'}
            transform={
              flip ? `rotate(-180 ${tileWidth / 2} ${tileHeight / 2})` : `rotate(0 ${tileWidth / 2} ${tileHeight / 2})`
            }>
            <g overflow="visible" transform={flip ? `scale(1,-1)` : ``}>
              <text
                stroke="black"
                fill="white"
                font-family="Verdana"
                font-weight="bold"
                x="50%"
                y={flip ? '0%' : '100%'}
                text-anchor="middle"
                alignment-baseline="middle"
                font-size="1.4em"
                shape-rendering="crispEdges">
                {selected ? (name ? firstName + ' ' + lastNamefirstLetter : name) : ''}
              </text>
            </g>
          </svg>
        );
      })}
    </svg>
  );
};

type PiecesSvgRendererProps = {
  pieceRecords: Record<string, PieceType>;
};

const PiecesSvgRenderer = ({ pieceRecords }: PiecesSvgRendererProps, context) => {
  const { act, data } = useBackend<BoardgameData>(context);

  const { pieces, currentUser } = data;
  const [flip] = useLocalState(context, 'flip', false);
  const width = 100 / data.boardInfo.width;
  const height = 100 / data.boardInfo.height;
  const board = document.getElementsByClassName('boardgame__board-inner')[0];
  let tileWidth: number = 0,
    tileHeight: number = 0;
  if (board) {
    const boardRect = board.getBoundingClientRect();

    const boardWidth = boardRect.width - 40; // Full width of the board
    const boardHeight = boardRect.height - 40; // Full height of the board

    tileWidth = boardWidth / data.boardInfo.width; // Width of a single tile
    tileHeight = boardHeight / data.boardInfo.height; // Height of a single tile
  }
  return (
    <svg width="100%" height="100%">
      {Object.keys(pieces).map((val, index) => {
        const { x, y, prevX, prevY, code } = pieces[val];
        const pieceType = pieceRecords[code];

        // Is the piece selected by currentUser?
        const selected = pieces[val].selected;

        // generate a unique color based on selected players name as a seed
        // make it so the same player always has the same color

        const flipY = data.boardInfo.height - y - 1;
        return (
          <svg
            className="boardgame__piecesvg"
            onmousedown={(e) => {
              // if the user has a piece selected, and this piece is not the selected piece, place the selected piece

              if (!selected) {
                act('pawnSelect', {
                  ckey: currentUser.ckey,
                  pId: val,
                });
              }
            }}
            onmouseup={(e) => {
              // Deselect the pawn if it is itself
            }}
            ondblclick={(e) => {
              act('pawnRemove', {
                id: val,
              });
            }}
            key={index}
            x={width * x + '%'}
            y={height * y + '%'}
            width={tileWidth + 'px'}
            height={tileHeight + 'px'}
            overflow="visible"
            style={{
              'opacity': selected ? 0.5 : 1,
            }}>
            <g
              transform={
                flip ? `rotate(180 ${tileWidth / 2} ${tileHeight / 2})` : `rotate(0 ${tileWidth / 2} ${tileHeight / 2})`
              }
              width="100%"
              height="100%"
              overflow="visible">
              <image
                transform={flip ? `rotate(180 50% 50%)` : ''}
                style={{
                  'cursor': 'pointer',
                }}
                x="0%"
                y="0%"
                width="100%"
                height="100%"
                xlinkHref={pieceType?.image}
              />
            </g>
          </svg>
        );
      })}
    </svg>
  );
};
