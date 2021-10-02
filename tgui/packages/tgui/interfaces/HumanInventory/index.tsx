import { toTitleCase } from 'common/string';
import { useBackend } from '../../backend';
import { Button, LabeledList, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { HumanInventoryData, HumanInventorySlot } from './types';

export const HumanInventory = (_props, context) => {
  const { data, act } = useBackend<HumanInventoryData>(context);

  return (
    <Window width={300} height={490} title={data.name}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section scrollable fill>
              <LabeledList>
                {data.slots.map((slot) => (
                  <Slot key={slot.slot} {...slot} />
                ))}
              </LabeledList>
            </Section>
          </Stack.Item>
          {Boolean(data.handcuffed || data.canSetInternal || data.internal) && (
            <Stack.Item>
              <Section>
                {Boolean(data.handcuffed) && <Button onClick={() => act('handcuff')}>Remove handcuffs</Button>}
                {Boolean(data.canSetInternal) && <Button onClick={() => act('internal')}>Set internals</Button>}
                {Boolean(data.internal) && <Button onClick={() => act('internal')}>Remove internals</Button>}
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const SlotNames = {
  [1]: 'Back',
  [2]: 'Mask',
  [4]: 'Left Hand',
  [5]: 'Right Hand',
  [6]: 'Belt',
  [7]: 'ID',
  [8]: 'Ears',
  [9]: 'Eyes',
  [10]: 'Gloves',
  [11]: 'Head',
  [12]: 'Shoes',
  [13]: 'Outer Suit',
  [14]: 'Uniform',
  [15]: 'Left Pocket',
  [16]: 'Right Pocket',
  [18]: 'Backpack',
};

type SlotProps = HumanInventorySlot;

const Slot = (props: SlotProps, context) => {
  const { act } = useBackend<HumanInventoryData>(context);
  const { slot, item } = props;

  return (
    <LabeledList.Item label={SlotNames[slot] ?? 'Unknown Slot'}>
      <Button color={item ? 'default' : 'transparent'} fluid onClick={() => act('slot', { slot })}>
        {item ? toTitleCase(item) : 'Nothing'}
      </Button>
    </LabeledList.Item>
  );
};
