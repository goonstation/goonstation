/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license MIT
 */

import { memo } from 'react';
import { Stack } from 'tgui-core/components';

import {
  propsAreEqual,
  ScannedItemExtraButtons,
  ScannedItemMainButton,
  ScannedItemProps,
} from './ScannedItem';

export const ScannedItemLegacyElectronicFrameMode = memo(
  (props: ScannedItemProps) => {
    const { ScannedItem, hide_allowed } = props;
    const { blueprint_available, has_item_mats } = ScannedItem;

    const mode = has_item_mats ? 'done' : 'blueprint';
    const available = blueprint_available;

    return (
      <Stack style={{ display: 'inline-flex' }}>
        <ScannedItemMainButton
          ScannedItem={ScannedItem}
          mode={mode}
          available={available}
        />
        <ScannedItemExtraButtons
          ScannedItem={ScannedItem}
          hide_allowed={hide_allowed}
        />
      </Stack>
    );
  },
  propsAreEqual,
);
