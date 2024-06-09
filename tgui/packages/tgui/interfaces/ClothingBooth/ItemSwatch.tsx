import { classes } from 'common/react';
import { Box, Tooltip } from '../../components';
import { SwatchBisectLeft } from './swatchForegroundShapes/bisect-left';
import { SwatchBisectRight } from './swatchForegroundShapes/bisect-right';
import { SwatchPolkadots } from './swatchForegroundShapes/polkadots';
import { SwatchClub } from './swatchForegroundShapes/club';
import { SwatchDiamond } from './swatchForegroundShapes/diamond';
import { SwatchHeart } from './swatchForegroundShapes/heart';
import { SwatchSpade } from './swatchForegroundShapes/spade';
import type { ClothingBoothItemData } from './type';

const SwatchLookup = {
  'bisect_left': SwatchBisectLeft,
  'bisect_right': SwatchBisectRight,
  'polkadots': SwatchPolkadots,
  'heart': SwatchClub,
  'diamond': SwatchDiamond,
  'club': SwatchHeart,
  'spade': SwatchSpade,
};

interface ItemSwatchProps extends ClothingBoothItemData {
  onSelect: () => void;
  selected: boolean;
}

export const ItemSwatch = (props: ItemSwatchProps) => {
  const {
    cost,
    name,
    onSelect,
    selected,
    swatch_background_colour,
    swatch_foreground_colour,
    swatch_foreground_shape,
  } = props;
  const swatchboxClasses = classes([selected && 'outline-color-good', 'clothingbooth__swatch_box']);
  const swatchiconClasses = classes([
    'clothingbooth__swatch_icon',
    `clothingbooth__swatch_icon_${swatch_foreground_shape}`,
  ]);
  const SwatchForegroundShape = SwatchLookup[swatch_foreground_shape] || null;

  return (
    <Tooltip content={`${name} (${cost}⪽)`} position="bottom">
      <Box
        className={swatchboxClasses}
        backgroundColor={swatch_background_colour}
        onClick={onSelect}
        width={2}
        height={2}>
        {swatch_foreground_shape && (
          <Box className={swatchiconClasses} height="100%" width="100%">
            {!!SwatchForegroundShape && (
              <SwatchForegroundShape colour={swatch_foreground_colour} className="clothingbooth__swatch_icon" />
            )}
          </Box>
        )}
      </Box>
    </Tooltip>
  );
};
