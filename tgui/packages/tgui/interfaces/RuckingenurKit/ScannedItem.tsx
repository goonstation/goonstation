/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license MIT
 */

import { memo } from 'react';
import { Button, Icon, Image, Stack } from 'tgui-core/components';
import { BooleanLike, shallowDiffers } from 'tgui-core/react';

import { useBackend } from '../../backend';
import {
  BlueprintButtonStyle,
  BlueprintMiniButtonStyle,
} from '../Manufacturer/constant';
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
    <Stack style={{ display: 'inline-flex' }}>
      <ScannedItemMainButton
        ScannedItem={ScannedItem}
        hide_allowed={hide_allowed}
        mode={mode}
        available={available}
      />
      <ScannedItemExtraButtons
        ScannedItem={ScannedItem}
        hide_allowed={hide_allowed}
      />
    </Stack>
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

type ScannedItemMainButtonData = ScannedItemProps & {
  mode: string;
  available: BooleanLike;
};
export const ScannedItemMainButton = (props: ScannedItemMainButtonData) => {
  const { act } = useBackend<RuckingenurKitData>();
  const { ScannedItem, mode, available } = props;
  const { name, imagePath, ref } = ScannedItem;

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

type ScannedItemExtraButtonsData = ScannedItemProps;
export const ScannedItemExtraButtons = (props: ScannedItemExtraButtonsData) => {
  const { act } = useBackend<RuckingenurKitData>();
  const { ScannedItem, hide_allowed } = props;
  const { description, ref, locked } = ScannedItem;

  return (
    <Stack.Item
      mx={BlueprintButtonStyle.MarginX}
      my={BlueprintButtonStyle.MarginY}
    >
      <Button
        width={BlueprintMiniButtonStyle.Width}
        height={
          BlueprintButtonStyle.Height / 2 - BlueprintMiniButtonStyle.Spacing / 4
        }
        py={BlueprintMiniButtonStyle.IconSize / 2}
        align="center"
        style={{ display: 'block' }}
        disabled={locked} // For visual feedback when locking
        tooltip={description ? description : null}
      >
        <Icon name="info" />
      </Button>

      <Button
        width={BlueprintMiniButtonStyle.Width}
        height={
          BlueprintButtonStyle.Height / 2 - BlueprintMiniButtonStyle.Spacing / 4
        }
        py={BlueprintMiniButtonStyle.IconSize / 2}
        align="center"
        style={{ display: 'block' }}
        onClick={() => act('lock', { op: ref })}
        color={locked ? 'red' : 'yellow'}
        tooltip={locked ? 'unlock blueprint' : 'lock blueprint'}
        disabled={!hide_allowed}
      >
        <Icon name={locked ? 'lock' : 'unlock'} />
      </Button>
    </Stack.Item>
  );
};
