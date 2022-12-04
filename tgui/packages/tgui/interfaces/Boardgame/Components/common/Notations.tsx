import { useBackend } from '../../../../backend';
import { Box, Flex } from '../../../../components';
import { BoardgameData } from '../../utils/types';

import { generateBoardNotationLetters } from '../../utils/notations';

export type NotationsProps = {
  direction: 'vertical' | 'horizontal';
};

export const HorizontalNotations = (props, context) => {
  const { data } = useBackend<BoardgameData>(context);
  const { width } = data.boardInfo;
  const { border, tileColor2 } = data.styling;

  const color = border || tileColor2 || 'black';

  const letters = generateBoardNotationLetters(width);

  return (
    <Flex
      style={{
        'background-color': color,
      }}
      className="boardgame__notations boardgame__notations-horizontal">
      {letters.map((letter, index) => (
        <Flex.Item key={index} grow={1}>
          <Box className="boardgame__notation-letter">{letter}</Box>
        </Flex.Item>
      ))}
    </Flex>
  );
};

export const VerticalNotations = (props, context) => {
  const { data } = useBackend<BoardgameData>(context);
  const { height } = data.boardInfo;
  const { border, tileColor2 } = data.styling;

  const color = border || tileColor2 || 'black';

  return (
    <Flex
      style={{
        'background-color': color,
      }}
      className="boardgame__notations boardgame__notations-vertical">
      {Array.from(Array(height).keys()).map((_, index) => (
        <Flex.Item className="boardgame__notations-number" key={index} grow={1}>
          {height - index}
        </Flex.Item>
      ))}
    </Flex>
  );
};
