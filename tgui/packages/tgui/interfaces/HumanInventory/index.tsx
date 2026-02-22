/**
 * @file
 * @copyright 2022
 * @author Lynncubus (https://github.com/Lynncubus)
 * @license MIT
 */

import { Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { HumanInventoryData, HumanInventorySlot } from './types';

const SLOT_NAMES = {
  slot_head: 'Head',
  slot_wear_mask: 'Mask',
  slot_glasses: 'Eyes',
  slot_ears: 'Ears',
  slot_l_hand: 'Left Hand',
  slot_r_hand: 'Right Hand',
  slot_gloves: 'Gloves',
  slot_shoes: 'Shoes',
  slot_belt: 'Belt',
  slot_w_uniform: 'Uniform',
  slot_wear_suit: 'Outer Suit',
  slot_back: 'Back',
  slot_wear_id: 'ID',
  slot_l_store: 'Left Pocket',
  slot_r_store: 'Right Pocket',
};

export const HumanInventory = () => {
  const { data, act } = useBackend<HumanInventoryData>();

  return (
    <Window width={300} height={490} title={data.name}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section scrollable fill>
              <LabeledList>
                {Object.entries(SLOT_NAMES).map(([slotId, name]) => {
                  const slot = data.slots.find((s) => s.id === slotId);
                  if (!slot) {
                    return null;
                  }
                  return <Slot key={slotId} name={name} slot={slot} />;
                })}
              </LabeledList>
            </Section>
          </Stack.Item>
          {Boolean(data.handcuffed || data.canSetInternal || data.internal) && (
            <Stack.Item>
              <Section>
                {Boolean(data.handcuffed) && (
                  <Button onClick={() => act('remove-handcuffs')}>
                    Remove handcuffs
                  </Button>
                )}
                {Boolean(data.canSetInternal) && (
                  <Button onClick={() => act('access-internals')}>
                    Set internals
                  </Button>
                )}
                {Boolean(data.internal) && (
                  <Button onClick={() => act('access-internals')}>
                    Remove internals
                  </Button>
                )}
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

type SlotProps = { name: string; slot: HumanInventorySlot };

const Slot = (props: SlotProps) => {
  const { act } = useBackend<HumanInventoryData>();
  const { slot, name } = props;
  const { id, item } = slot;

  return (
    <LabeledList.Item label={name}>
      <Button
        color={item ? 'default' : 'transparent'}
        fluid
        onClick={() => act('access-slot', { id })}
      >
        {item ? item : 'Nothing'}
      </Button>
    </LabeledList.Item>
  );
};
