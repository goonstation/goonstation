import { BoardgameData } from '../../utils';
import { useBackend } from '../../../../backend';
import { fetchPalettes, PieceSetupType } from '../../games';
import { useActions, useStates } from '../../utils';
import { Box, Button, Flex } from '../../../../components';

export const Palettes = (props, context) => {
  const { act, data } = useBackend<BoardgameData>(context);
  const { isExpanded } = useStates(context);
  return (
    <Box className={'boardgame__palettes'}>
      {fetchPalettes().map((set, i) => (
        <Box key={set.name}>
          <Box className={'boardgame__palettes-header'}>
            <PaletteExpandButton index={i} setId={set.name} />
          </Box>

          <Flex className={`boardgame__palettes-set ${isExpanded(i) ? '' : 'boardgame__palettes-set-minimized'}`}>
            {set.pieces.map((piece, index) => (
              <Palette key={index} piece={piece} />
            ))}
          </Flex>
        </Box>
      ))}
    </Box>
  );
};

type PaletteProps = {
  piece: PieceSetupType;
};

const Palette = ({ piece }: PaletteProps, context) => {
  const { act, data } = useBackend<BoardgameData>(context);
  const { currentUser } = data;

  const { paletteSet } = useActions(act);

  return (
    <Flex.Item
      className="boardgame__palettes-set-piece"
      key={piece.name}
      onMouseDown={() => paletteSet(currentUser.ckey, piece.code)}>
      <img src={piece.image} />
    </Flex.Item>
  );
};

type PaletteExpandButtonProps = {
  index: number;
  setId: string;
};

const PaletteExpandButton = ({ index, setId }: PaletteExpandButtonProps, context) => {
  const { isExpanded, togglePalette } = useStates(context);
  return (
    <Button.Checkbox
      className={'boardgame__palettes-set-toggle'}
      checked={isExpanded(index)}
      onClick={() => togglePalette(index)}>
      {setId}
    </Button.Checkbox>
  );
};
