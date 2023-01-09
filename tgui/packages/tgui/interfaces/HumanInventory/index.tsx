import { useBackend } from '../../backend';
import { Button, LabeledList, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { HumanInventoryData, HumanInventorySlot } from './types';

const SLOT_NAMES = {
  'slot_head': 'Head',
  'slot_wear_mask': 'Mask',
  'slot_glasses': 'Eyes',
  'slot_ears': 'Ears',
  'slot_l_hand': 'Left Hand',
  'slot_r_hand': 'Right Hand',
  'slot_gloves': 'Gloves',
  'slot_shoes': 'Shoes',
  'slot_belt': 'Belt',
  'slot_w_uniform': 'Uniform',
  'slot_wear_suit': 'Outer Suit',
  'slot_back': 'Back',
  'slot_wear_id': 'ID',
  'slot_l_store': 'Left Pocket',
  'slot_r_store': 'Right Pocket',
};

export const HumanInventory = (_props, context) => {
  const { data, act } = useBackend<HumanInventoryData>(context);

  return (
    <Window width={300} height={490} title={data.name}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section scrollable fill>
              <LabeledList>
                {Object.entries(SLOT_NAMES).map(([slotId, name]) => {
                  const slot = data.slots.find((s) => s.id === slotId);

                  return <Slot key={slotId} name={name} slot={slot} />;
                })}
              </LabeledList>
            </Section>
          </Stack.Item>
          {Boolean(data.handcuffed || data.canSetInternal || data.internal) && (
            <Stack.Item>
              <Section>
                {Boolean(data.handcuffed) && <Button onClick={() => act('remove-handcuffs')}>Remove handcuffs</Button>}
                {Boolean(data.canSetInternal) && <Button onClick={() => act('access-internals')}>Set internals</Button>}
                {Boolean(data.internal) && <Button onClick={() => act('access-internals')}>Remove internals</Button>}
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

type SlotProps = { name: string; slot: HumanInventorySlot };

const Slot = (props: SlotProps, context) => {
  const { act } = useBackend<HumanInventoryData>(context);
  const { slot, name } = props;
  const { id, item, obstructed } = slot;

  let getItemName = function getItemName(obstructed, item) {
    if (obstructed) {
      return 'Obstructed';
    }
    if (!item) {
      return 'Nothing';
    }
    return item;
  };

  return (
    <LabeledList.Item label={name}>
      <Button color={!obstructed && item ? 'default' : 'transparent'} fluid onClick={() => act('access-slot', { slot })}>
        {getItemName(obstructed, item)}
      </Button>
    </LabeledList.Item>
  );
};



