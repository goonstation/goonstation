declare const React;

import { classes } from 'common/react';
import { useBackend, useLocalState } from '../../../backend';
import { Box, Flex } from '../../../components';
import { BoardgameData } from '../types';

export type NotationsProps = {
  direction: 'vertical' | 'horizontal';
};

export const Notations = ({ direction }: NotationsProps, context) => {
  const { act, data } = useBackend<BoardgameData>(context);
  const { boardInfo } = data;
  const { height, width } = boardInfo;
  const { currentUser } = data;
  const { tileColour1, tileColour2, border } = data.styling;
  const [flip, setFlip] = useLocalState(context, 'flip', false);
  let chars = 'abcdefghijklmnopqrstuvwxyz'.split('').slice(0, width);

  if (flip) {
    chars = chars.reverse();
  }

  const heightPercentage = 100 / height;
  const widthPercentage = 100 / width;
  // loop through the board width and create a box for each

  let notationDirectionClass = '';
  if (direction === 'vertical') {
    notationDirectionClass = 'boardgame__verticalnotations';
  } else {
    notationDirectionClass = `boardgame__piece-set-horizontal`;
  }

  return (
    <Flex.Item
      onMouseUp={() => {
        act('paletteClear', {
          ckey: currentUser.ckey,
        });

        if (currentUser.selected) {
          act('pawnRemove', {
            id: currentUser.selected,
          });
        }
      }}
      style={{
        'background-color': border || tileColour2,
        'color': tileColour1,
      }}
      className={classes(['boardgame__notations', notationDirectionClass])}>
      {Array.from(Array(direction === 'vertical' ? height : width).keys()).map((i) => {
        // Reverse i if it's > width or height
        // example, 0,1,2,3,2,1,0
        return (
          <Box
            key={i}
            style={{
              'height': direction === 'vertical' ? `${heightPercentage}%` : 'auto',
            }}>
            {direction === 'vertical' ? (flip ? i + 1 : height - i) : chars[i]}
          </Box>
        );
      })}
    </Flex.Item>
  );
};
