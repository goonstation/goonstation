import { HorizontalNotations, VerticalNotations } from '../';
import { Flex } from '../../../../components';
import { BoardgameData } from '../../utils/types';
import { useBackend } from '../../../../backend';
import { useActions } from '../../utils/config';
import CheckerBoard from './styles/checkerboard';

export const Board = (props, context) => {
  const { act, data } = useBackend<BoardgameData>(context);
  const { pieceDeselect } = useActions(act);

  return (
    <Flex className="boardgame__wrapper">
      <div className={`boardgame__board-inner`}>
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
      </div>
    </Flex>
  );
};

const DesignSelector = (props, context) => {
  const { data } = useBackend<BoardgameData>(context);
  const { design } = data.boardInfo;
  switch (design) {
    // Apply new designs here
    case 'checkerboard':
      return <CheckerBoard />;
    default:
      return <div>Unknown design: {design}</div>;
  }
};
