/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license MIT
 */

import { Button, Icon, Image, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import {
  BlueprintButtonStyle,
  BlueprintMiniButtonStyle,
} from '../Manufacturer/constant';
import { RKitData, ScannedItemData } from './type';

export const RKit = () => {
  const { data } = useBackend<RKitData>();
  const { scanned_items } = data;

  return (
    <Window width={925} height={420}>
      <Window.Content>
        <Section title="Scanned Items" scrollable fill>
          {scanned_items.map((scanned_item) => (
            <ScannedItem ScannedItem={scanned_item} key={scanned_item.ref} />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

interface ScannedItemProps {
  ScannedItem: ScannedItemData;
}
const ScannedItem = (props: ScannedItemProps) => {
  const { ScannedItem } = props;

  return (
    <Stack style={{ display: 'inline-flex' }}>
      <ScannedItemMainButton ScannedItem={ScannedItem} />
      <ScannedItemExtraButtons ScannedItem={ScannedItem} />
    </Stack>
  );
};

type ScannedItemMainButtonData = ScannedItemProps;
const ScannedItemMainButton = (props: ScannedItemMainButtonData) => {
  const { data, act } = useBackend<RKitData>();
  const { hide_allowed, olde } = data;
  const { name, has_item_mats, blueprint_available, locked, imagePath, ref } =
    props.ScannedItem;

  const mode = has_item_mats && olde ? 'done' : 'blueprint';
  const available = blueprint_available && (!locked || hide_allowed || olde);

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
const ScannedItemExtraButtons = (props: ScannedItemExtraButtonsData) => {
  const { data, act } = useBackend<RKitData>();
  const { hide_allowed } = data;
  const { description, ref, locked } = props.ScannedItem;

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
