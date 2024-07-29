import { Box, Button, Flex } from 'tgui-core/components';

import { useBackend } from '../../../../backend';
import { fetchPalettes, PieceSetupType } from '../../games';
import { BoardgameData } from '../../utils';
import { useActions, useStates } from '../../utils';

export const Palettes = () => {
  const { isExpanded } = useStates();
  return (
    <Box className={'boardgame__palettes'}>
      {fetchPalettes().map((set, i) => (
        <Box key={set.name}>
          <Box className={'boardgame__palettes-header'}>
            <PaletteExpandButton index={i} setId={set.name} />
          </Box>

          <Flex
            className={`boardgame__palettes-set ${isExpanded(i) ? '' : 'boardgame__palettes-set-minimized'}`}
          >
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

const Palette = ({ piece }: PaletteProps) => {
  const { act, data } = useBackend<BoardgameData>();
  const { currentUser } = data;

  const { paletteSet } = useActions(act);

  return (
    <Flex.Item
      className="boardgame__palettes-set-piece"
      key={piece.name}
      onMouseDown={() => paletteSet(currentUser.ckey, piece.code)}
    >
      <img src={piece.image} />
    </Flex.Item>
  );
};

type PaletteExpandButtonProps = {
  index: number;
  setId: string;
};

const PaletteExpandButton = ({ index, setId }: PaletteExpandButtonProps) => {
  const { isExpanded, togglePalette } = useStates();
  return (
    <Button.Checkbox
      className={'boardgame__palettes-set-toggle'}
      checked={isExpanded(index)}
      onClick={() => togglePalette(index)}
    >
      {setId}
    </Button.Checkbox>
  );
};
