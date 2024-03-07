import { useLocalState } from '../../backend';
import { Button, Section, Stack } from '../../components';
import { ClothingBoothSlotKey } from './type';

export const SlotFilters = (_, context) => {
  const [slotFilters, setSlotFilters] = useLocalState<Partial<Record<ClothingBoothSlotKey, boolean>>>(context, 'slotFilters', {});
  const mergeSlotFilter = (filter: ClothingBoothSlotKey) =>
    setSlotFilters({
      ...slotFilters,
      [filter]: !slotFilters[filter],
    });
  const [tagModal, setTagModal] = useLocalState(context, 'tagModal', false);
  const [tagFilters] = useLocalState<Partial<Record<string, boolean>>>(context, 'tagFilters', {});

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item>
          <Button fluid align="center" color={Object.values(tagFilters).some((tagFilter) => tagFilter === true) && "good"} onClick={() => setTagModal(!tagModal)}>
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
            onClick={() => mergeSlotFilter(ClothingBoothSlotKey.Mask)}>
            Mask
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Glasses]}
            onClick={() => mergeSlotFilter(ClothingBoothSlotKey.Glasses)}>
            Glasses
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Gloves]}
            onClick={() => mergeSlotFilter(ClothingBoothSlotKey.Gloves)}>
            Gloves
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Headwear]}
            onClick={() => mergeSlotFilter(ClothingBoothSlotKey.Headwear)}>
            Headwear
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Shoes]}
            onClick={() => mergeSlotFilter(ClothingBoothSlotKey.Shoes)}>
            Shoes
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Suit]}
            onClick={() => mergeSlotFilter(ClothingBoothSlotKey.Suit)}>
            Suit
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Uniform]}
            onClick={() => mergeSlotFilter(ClothingBoothSlotKey.Uniform)}>
            Uniform
          </Button.Checkbox>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
