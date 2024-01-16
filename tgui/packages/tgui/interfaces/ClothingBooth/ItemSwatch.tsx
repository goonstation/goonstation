import { classes } from 'common/react';
import { ColorBox, Tooltip } from '../../components';
import type { ClothingBoothItemData } from './type';

interface ItemSwatchProps extends ClothingBoothItemData {
  onSelect: () => void;
  selected: boolean;
}

export const ItemSwatch = (props: ItemSwatchProps) => {
  const { name, onSelect, selected, swatch_background_colour } = props;
  const cn = classes([selected && 'outline-color-label']);
  return (
    <Tooltip content={name}>
      <ColorBox className={cn} backgroundColor={swatch_background_colour} onClick={onSelect} width={2} height={2} />
    </Tooltip>
  );
};
