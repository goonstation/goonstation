/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license MIT
 */

import { memo } from 'react';
import { Button, Image, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { BlueprintButtonStyle } from '../Manufacturer/constant';
import {
  propsAreEqual,
  ScannedItemExtraButtons,
  ScannedItemMainButtonData,
  ScannedItemProps,
} from '.';
import { RuckingenurKitData } from './type';

export const ScannedItemLegacyElectronicFrameMode = memo(
  (props: ScannedItemProps) => {
    const { ScannedItem, hide_allowed } = props;

    return (
      <Stack style={{ display: 'inline-flex' }}>
        <ScannedItemLegacyElectronicFrameModeMainButton
          ScannedItem={ScannedItem}
          hide_allowed={hide_allowed}
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

const ScannedItemLegacyElectronicFrameModeMainButton = (
  props: ScannedItemMainButtonData,
) => {
  const { act } = useBackend<RuckingenurKitData>();
  const { ScannedItem } = props;
  const { name, has_item_mats, blueprint_available, imagePath, ref } =
    ScannedItem;

  const mode = has_item_mats ? 'done' : 'blueprint';
  const available = blueprint_available;

  return (
    <Stack.Item
      ml={BlueprintButtonStyle.MarginX}
      my={BlueprintButtonStyle.MarginY}
    >
      <Button
        width={BlueprintButtonStyle.Width}
        height={BlueprintButtonStyle.Height}
        px={0}
        className="Button--ComplexContent"
        onClick={() => act(mode, { op: ref })}
        disabled={!available}
        tooltip={!available ? 'Blueprint Disabled' : null}
      >
        <Stack height="100%">
          <Stack.Item basis="60px">
            {imagePath && (
              <Image
                src={imagePath}
                backgroundColor="rgba(0,0,0,0.2)"
                height="100%"
              />
            )}
          </Stack.Item>
          <Stack.Item grow mx={1} align="center">
            {name}
          </Stack.Item>
        </Stack>
      </Button>
    </Stack.Item>
  );
};
