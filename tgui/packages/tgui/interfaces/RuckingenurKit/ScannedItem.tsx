/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license MIT
 */

import { memo } from 'react';
import { BooleanLike, shallowDiffers } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { ItemButton } from '../../components/goonstation/ItemButton';
import { RuckingenurKitData, ScannedItemData } from './type';

export type ScannedItemProps = Pick<RuckingenurKitData, 'hide_allowed'> & {
  ScannedItem: ScannedItemData;
};
export const ScannedItem = memo((props: ScannedItemProps) => {
  const { ScannedItem, hide_allowed } = props;
  const { blueprint_available, locked } = ScannedItem;

  const mode = 'blueprint';
  const available = blueprint_available && (!locked || hide_allowed);

  return (
    <ScannedItemButton
      ScannedItem={ScannedItem}
      mode={mode}
      available={available}
      hide_allowed={hide_allowed}
    />
  );
}, propsAreEqual);

export function propsAreEqual(
  prevProps: ScannedItemProps,
  nextProps: ScannedItemProps,
) {
  const { ScannedItem: prevScannedItem, ...prevRest } = prevProps;
  const { ScannedItem: nextScannedItem, ...nextRest } = nextProps;
  return (
    !shallowDiffers(prevScannedItem, nextScannedItem) &&
    !shallowDiffers(prevRest, nextRest)
  );
}

type ScannedItemButtonProps = ScannedItemProps & {
  mode: string;
  available: BooleanLike;
};
export const ScannedItemButton = (props: ScannedItemButtonProps) => {
  const { act } = useBackend<RuckingenurKitData>();
  const { ScannedItem, hide_allowed, mode, available } = props;
  const { description, name, imagePath, ref, locked } = ScannedItem;

  return (
    <ItemButton
      image={imagePath}
      name={name}
      disabled={!available}
      tooltip={!available ? 'Blueprint Disabled' : undefined}
      onMainButtonClick={() => act(mode, { op: ref })}
      sideButton1={{
        icon: 'info',
        disabled: locked,
        tooltip: description ? description : null,
      }}
      sideButton2={{
        icon: locked ? 'lock' : 'unlock',
        color: locked ? 'red' : 'yellow',
        tooltip: locked ? 'unlock blueprint' : 'lock blueprint',
        disabled: !hide_allowed,
        onClick: () => act('lock', { op: ref }),
      }}
    />
  );
};
