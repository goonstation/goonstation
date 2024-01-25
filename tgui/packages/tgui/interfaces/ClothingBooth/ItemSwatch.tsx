import { classes } from 'common/react';
import { Box, Tooltip } from '../../components';
import type { ClothingBoothItemData } from './type';

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
  return (
    <Tooltip content={`${name} (${cost}⪽)`} position="bottom">
      <Box
        className={swatchboxClasses}
        backgroundColor={swatch_background_colour}
        onClick={onSelect}
        width={2}
        height={2}>
        {swatch_foreground_shape && (
          <Box className={swatchiconClasses} backgroundColor={swatch_foreground_colour} height="100%" width="100%" />
        )}
      </Box>
    </Tooltip>
  );
};
