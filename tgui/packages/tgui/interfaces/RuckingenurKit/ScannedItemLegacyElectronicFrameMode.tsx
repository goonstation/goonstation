/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license MIT
 */

import { memo } from 'react';

import {
  propsAreEqual,
  ScannedItemButton,
  ScannedItemProps,
} from './ScannedItem';

export const ScannedItemLegacyElectronicFrameMode = memo(
  (props: ScannedItemProps) => {
    const { ScannedItem, hide_allowed } = props;
    const { blueprint_available, has_item_mats } = ScannedItem;

    const mode = has_item_mats ? 'done' : 'blueprint';
    const available = blueprint_available;

    return (
      <ScannedItemButton
        ScannedItem={ScannedItem}
        mode={mode}
        available={available}
        hide_allowed={hide_allowed}
      />
    );
  },
  propsAreEqual,
);
