import { useBackend } from '../../backend';
import { Button, LabeledList, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { HumanInventoryData, HumanInventorySlot } from './types';

const HEAD_SLOTS = {
  'slot_head': 'Head',
  'slot_wear_mask': 'Mask',
  'slot_glasses': 'Eyes',
  'slot_ears': 'Ears',
};

const BODY_SLOTS = {
  'slot_wear_suit': 'Outer Suit',
  'slot_w_uniform': 'Uniform',
  'slot_gloves': 'Gloves',
  'slot_shoes': 'Shoes',
};

const MISC_SLOTS = {
  'slot_l_hand': 'Left Hand',
  'slot_r_hand': 'Right Hand',
  'slot_back': 'Back',
  'slot_belt': 'Belt',
  'slot_wear_id': 'ID',
  'slot_l_store': 'Left Pocket',
  'slot_r_store': 'Right Pocket',
};

export const HumanInventory = (_props, context) => {
  const { data, act } = useBackend<HumanInventoryData>(context);

  return (
    <Window width={340} height={570} title={data.name}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Head">
              <LabeledList>
                {Object.entries(HEAD_SLOTS).map(([slotId, name]) => {
                  const slot = data.slots.find((s) => s.id === slotId);
                  return <Slot key={slotId} name={name} slot={slot} />;
                })}
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Body">
              <LabeledList>
                {Object.entries(BODY_SLOTS).map(([slotId, name]) => {
                  const slot = data.slots.find((s) => s.id === slotId);
                  return <Slot key={slotId} name={name} slot={slot} />;
                })}
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Misc">
              <LabeledList>
                {Object.entries(MISC_SLOTS).map(([slotId, name]) => {
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
      <Button color={obstructed || !item ? 'transparent' : undefined} fluid onClick={() => act('access-slot', { slot })}>
        {getItemName(obstructed, item)}
      </Button>
    </LabeledList.Item>
  );
};



