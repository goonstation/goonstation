import { classes } from 'common/react';
import { ColorBox, Tooltip } from '../../components';
import type { ClothingBoothItemData } from './type';

interface ItemSwatchProps extends ClothingBoothItemData {
  onSelect: () => void;
  selected: boolean;
}

export const ItemSwatch = (props: ItemSwatchProps) => {
  const { cost, name, onSelect, selected, swatch_background_colour } = props;
  const cn = classes([selected && 'outline-color-good', 'clothingbooth__swatch']);
  return (
    <Tooltip content={`${name} (${cost}⪽)`} position="bottom">
      <ColorBox className={cn} backgroundColor={swatch_background_colour} onClick={onSelect} width={2} height={2} />
    </Tooltip>
  );
};
