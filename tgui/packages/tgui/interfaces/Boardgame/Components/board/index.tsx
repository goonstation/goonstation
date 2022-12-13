import { HorizontalNotations, VerticalNotations } from '../';
import { Flex, Box } from '../../../../components';
import { BoardgameData } from '../../utils';
import { useBackend } from '../../../../backend';
import { useActions } from '../../utils';
import CheckerBoard from './styles/checkerboard';

export const Board = (props, context) => {
  const { act, data } = useBackend<BoardgameData>(context);
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
            }}>
            <DesignSelector />
          </Flex.Item>
          <VerticalNotations />
        </Flex>
        <HorizontalNotations />
      </Box>
    </Flex>
  );
};

const DesignSelector = (props, context) => {
  const { data } = useBackend<BoardgameData>(context);
  const { boardstyle } = data.boardInfo;
  switch (boardstyle) {
    // Apply new designs here
    case 'checkerboard':
      return <CheckerBoard interactable />;
    default:
      return <div>Unknown design: {boardstyle}</div>;
  }
};
