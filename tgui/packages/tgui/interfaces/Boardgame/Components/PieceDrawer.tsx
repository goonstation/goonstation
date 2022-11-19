declare const React;

import { useBackend, useLocalState } from '../../../backend';
import { BoardgameData } from '../types';
import { Piece } from './';
import { sets } from '../Pieces/sets';
import { Box, Button, Flex } from '../../../components';

export const PieceDrawer = (orps, context) => {
  const { act, data } = useBackend<BoardgameData>(context);
  const { currentUser } = data;
  const [expandedSets, setExpandedSets] = useLocalState<boolean[]>(
    context,
    `expandedSets`,
    new Array(sets.length).fill(true)
  );
  return (
    <Box
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
      className={'boardgame__piece-set-wrapper'}>
      {sets.map((set, i) => (
        <Box key={set.name}>
          <Box className={'boardgame__piece-set-header'}>
            <ExpandedSetsButton index={i} setId={set.name} />
          </Box>

          <Flex
            direction={'row'}
            className={`boardgame__piece-set  ${!expandedSets[i] ? 'boardgame__piece-set-minimized' : ''}`}>
            {set.pieces.map((piece) => (
              <Flex.Item
                className="boardgame__piece-set__piece"
                key={piece.name}
                onMouseDown={() => {
                  act('paletteSet', {
                    ckey: currentUser.ckey,
                    code: piece.fenCode,
                  });
                }}>
                <Piece piece={piece} isSetPiece />
              </Flex.Item>
            ))}
          </Flex>
        </Box>
      ))}
    </Box>
  );
};

type ExpandedSetsButtonProps = {
  index: number;
  setId: string;
};

const ExpandedSetsButton = ({ index, setId }: ExpandedSetsButtonProps, context) => {
  const [expandedSets, setExpandedSets] = useLocalState<boolean[]>(
    context,
    `expandedSets`,
    new Array(sets.length).fill(true)
  );
  return (
    <Button.Checkbox
      className="boardgame__piece-set-toggle"
      checked={expandedSets[index]}
      onClick={() => {
        const newExpandedSets = [...expandedSets];
        newExpandedSets[index] = !newExpandedSets[index];
        setExpandedSets(newExpandedSets);
      }}>
      {setId}
    </Button.Checkbox>
  );
};
