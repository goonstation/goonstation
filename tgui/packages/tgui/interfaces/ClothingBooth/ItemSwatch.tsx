/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { classes } from 'common/react';
import { Box, Tooltip } from 'tgui-core/components';

import {
  SwatchBisectLeft,
  SwatchBisectRight,
  SwatchClub,
  SwatchDiamond,
  SwatchHearts,
  SwatchPolkaDots,
  SwatchSpade,
} from './swatchForegroundShapes';
import type { ClothingBoothItemData } from './type';

const SwatchLookup = {
  bisect_left: SwatchBisectLeft,
  bisect_right: SwatchBisectRight,
  polkadots: SwatchPolkaDots,
  club: SwatchClub,
  diamond: SwatchDiamond,
  heart: SwatchHearts,
  spade: SwatchSpade,
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
    swatch_background_color,
    swatch_foreground_color,
    swatch_foreground_shape,
  } = props;
  const swatchboxClasses = classes([
    selected && 'outline-color-good',
    'clothingbooth__swatch-box',
  ]);
  const swatchiconClasses = classes([
    'clothingbooth__swatch-icon',
    `clothingbooth__swatch-icon--${swatch_foreground_shape}`,
  ]);
  const SwatchForegroundShape =
    (swatch_foreground_shape && SwatchLookup[swatch_foreground_shape]) ?? null;

  return (
    <Tooltip content={`${name} (${cost}⪽)`} position="bottom">
      <Box
        className={swatchboxClasses}
        backgroundColor={swatch_background_color}
        onClick={onSelect}
        width={2}
        height={2}
        m="0.2em"
      >
        {swatch_foreground_shape && (
          <Box className={swatchiconClasses} height="100%" width="100%">
            {!!SwatchForegroundShape && (
              <SwatchForegroundShape
                color={swatch_foreground_color}
                className="clothingbooth__swatch_icon"
              />
            )}
          </Box>
        )}
      </Box>
    </Tooltip>
  );
};
