declare const React;
declare const Byond;
declare const window;

import { Window } from '../../layouts';
import { Box, Button, Flex } from '../../components';
import { useBackend, useLocalState } from '../../backend';
import { Pattern } from './Patterns';
import { BoardgameData } from './types';

import { PieceDrawer } from './Components/PieceDrawer';

import { FenCodeSettings, Notations, HeldPieceRenderer } from './Components';

export const Boardgame = (_props, context) => {
  const { act, data } = useBackend<BoardgameData>(context);

  const { currentUser } = data;
  const { name, pattern } = data.boardInfo;
  const { useNotations } = data.styling;

  const [configModalOpen, setConfigModalOpen] = useLocalState(context, 'configModalOpen', false);
  const [flip, setFlip] = useLocalState(context, 'flip', false);

  const [, setMouseCoords] = useLocalState<{
    x: number;
    y: number;
  }>(context, 'mouseCoords', { x: 0, y: 0 });

  return (
    <Window title={name} width={580} height={512}>
      <FenCodeSettings />
      <Window.Content
        onMouseMove={(e) => {
          setMouseCoords({
            x: e.clientX,
            y: e.clientY,
          });
        }}
        onMouseUp={(e) => {
          // If mouse is released outside boardgame__board-inner, delete the held piece
          const board = document.getElementsByClassName('boardgame__board-inner')[0];
          if (board) {
            let x = e.clientX;
            let y = e.clientY;
            const boardRect = board.getBoundingClientRect();
            if (x < boardRect.left || x > boardRect.right || y < boardRect.top || y > boardRect.bottom) {
              act('heldPiece', { heldPiece: null });
            }
          }
        }}
        fitted
        className="boardgame__window">
        {(currentUser?.palette || currentUser?.selected) && <HeldPieceRenderer />}
        <Box className="boardgame__debug">
          <Button.Checkbox checked={flip} onClick={() => setFlip(!flip)}>
            Flip board
          </Button.Checkbox>
          <Button title={'Setup'} icon={'cog'} onClick={() => setConfigModalOpen(true)} />
        </Box>
        <Flex className="boardgame__wrapper">
          <Flex.Item grow={1} className={`boardgame__board-inner`}>
            {!!useNotations && <Notations direction={'horizontal'} />}
            <Flex className={`boardgame__board`}>
              {!!useNotations && <Notations direction={'vertical'} />}
              <Pattern pattern={pattern} />
              {!!useNotations && <Notations direction={'vertical'} />}
            </Flex>
            {!!useNotations && <Notations direction={'horizontal'} />}
          </Flex.Item>
          <PieceDrawer />
        </Flex>
      </Window.Content>
    </Window>
  );
};

Boardgame.defaultHooks = {
  onComponentDidUpdate: (lastProps, nextProps) => {
    // Adjust window size
    const pieceSetPadding = 100; // Add 100 pixels to the width
    const titlebarHeightPadding = 32;
    let width = 500;
    let height = 400;
    // Fetch boardgame__wrapper element and get its width and height
    const wrapper = document.getElementsByClassName('boardgame__wrapper')[0];
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
      width = shortestSide + pieceSetPadding;
      height = shortestSide + titlebarHeightPadding;
    }

    Byond.winset(window.__windowId__, {
      size: `${width}x${height}`,
    });
  },
};
