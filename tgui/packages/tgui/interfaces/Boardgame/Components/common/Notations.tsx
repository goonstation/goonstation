import { useBackend } from '../../../../backend';
import { Box, Flex } from '../../../../components';
import { BoardgameData } from '../../utils';

import { generateBoardNotationLetters } from '../../utils/notations';
import { useStates } from '../../utils';

export type NotationsProps = {
  direction: 'vertical' | 'horizontal';
};

export const HorizontalNotations = (props, context) => {
  const { data } = useBackend<BoardgameData>(context);
  const { width } = data.boardInfo;
  const { border, tileColor2 } = data.styling;
  const { isFlipped } = useStates(context);

  const color = border || tileColor2 || 'black';

  let letters = generateBoardNotationLetters(width);
  if (isFlipped) {
    letters = letters.reverse();
  }

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
  const { isFlipped } = useStates(context);

  const color = border || tileColor2 || 'black';

  let numbers = Array.from(Array(height).keys());
  if (isFlipped) {
    numbers = numbers.reverse();
  }

  return (
    <Flex
      style={{
        'background-color': color,
      }}
      className="boardgame__notations boardgame__notations-vertical">
      {numbers.map((_, index) => (
        <Flex.Item className="boardgame__notations-number" key={index} grow={1}>
          {isFlipped ? index + 1 : height - index}
        </Flex.Item>
      ))}
    </Flex>
  );
};
