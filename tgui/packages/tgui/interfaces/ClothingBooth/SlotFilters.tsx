import { useLocalState } from '../../backend';
import { Button, Section, Stack } from '../../components';
import { ClothingBoothSlotKey } from './type';

export const SlotFilters = (_, context) => {
  const [slotFilters, setSlotFilters] = useLocalState<Partial<Record<ClothingBoothSlotKey, boolean>>>(context, 'slotFilters', {});
  const setSlotFilter = (filter: ClothingBoothSlotKey) =>
    setSlotFilters({
      ...slotFilters,
      [filter]: !slotFilters[filter],
    });
  const [tagModal, setTagModal] = useLocalState(context, 'tagModal', false);

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item>
          <Button fluid align="center" onClick={() => setTagModal(!tagModal)}>
            Tags
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button fluid align="center" onClick={() => setSlotFilters({})}>
            Clear Slots
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Mask]}
            onClick={() => setSlotFilter(ClothingBoothSlotKey.Mask)}>
            Mask
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Glasses]}
            onClick={() => setSlotFilter(ClothingBoothSlotKey.Glasses)}>
            Glasses
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Gloves]}
            onClick={() => setSlotFilter(ClothingBoothSlotKey.Gloves)}>
            Gloves
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Headwear]}
            onClick={() => setSlotFilter(ClothingBoothSlotKey.Headwear)}>
            Headwear
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Shoes]}
            onClick={() => setSlotFilter(ClothingBoothSlotKey.Shoes)}>
            Shoes
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Suit]}
            onClick={() => setSlotFilter(ClothingBoothSlotKey.Suit)}>
            Suit
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Uniform]}
            onClick={() => setSlotFilter(ClothingBoothSlotKey.Uniform)}>
            Uniform
          </Button.Checkbox>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
