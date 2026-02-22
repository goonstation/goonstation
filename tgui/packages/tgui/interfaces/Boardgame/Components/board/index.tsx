import { Box, Flex } from 'tgui-core/components';

import { useBackend } from '../../../../backend';
import { BoardgameData } from '../../utils';
import { useActions } from '../../utils';
import { HorizontalNotations, VerticalNotations } from '../';
import CheckerBoard from './styles/checkerboard';

export const Board = () => {
  const { act, data } = useBackend<BoardgameData>();
  const { pieceDeselect } = useActions(act);

  return (
    <Flex className="boardgame__wrapper">
      <Box className={`boardgame__board-inner`}>
        <HorizontalNotations />
        <Flex className={`boardgame__board`}>
          <VerticalNotations />
          <Flex.Item
            grow
            onmouseleave={() => {
              if (data.currentUser?.selected) {
                pieceDeselect(data.currentUser.ckey);
              }
            }}
          >
            <DesignSelector />
          </Flex.Item>
          <VerticalNotations />
        </Flex>
        <HorizontalNotations />
      </Box>
    </Flex>
  );
};

const DesignSelector = () => {
  const { data } = useBackend<BoardgameData>();
  const { boardstyle } = data.boardInfo;
  switch (boardstyle) {
    // Apply new designs here
    case 'checkerboard':
      return <CheckerBoard />;
    default:
      return <div>Unknown design: {boardstyle}</div>;
  }
};
