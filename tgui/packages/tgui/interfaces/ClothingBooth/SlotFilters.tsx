import { useLocalState } from '../../backend';
import { Button, Section, Stack } from '../../components';
import { ClothingBoothSlotKey } from './type';

export const SlotFilters = (_, context) => {
  const [slotFilters, setSlotFilters] = useLocalState<Partial<Record<ClothingBoothSlotKey, boolean>>>(context, 'slotFilters', {});
  const toggleSlotFilter = (filter: ClothingBoothSlotKey) =>
    setSlotFilters({
      ...slotFilters,
      [filter]: !slotFilters[filter],
    });

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item>
          <Button fluid align="center" onClick={() => setSlotFilters({})}>
            Clear Filters
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button fluid align="center">
            Tags
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Mask]}
            onClick={() => toggleSlotFilter(ClothingBoothSlotKey.Mask)}>
            Mask
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Glasses]}
            onClick={() => toggleSlotFilter(ClothingBoothSlotKey.Glasses)}>
            Glasses
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Gloves]}
            onClick={() => toggleSlotFilter(ClothingBoothSlotKey.Gloves)}>
            Gloves
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Headwear]}
            onClick={() => toggleSlotFilter(ClothingBoothSlotKey.Headwear)}>
            Headwear
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Shoes]}
            onClick={() => toggleSlotFilter(ClothingBoothSlotKey.Shoes)}>
            Shoes
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Suit]}
            onClick={() => toggleSlotFilter(ClothingBoothSlotKey.Suit)}>
            Suit
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!slotFilters[ClothingBoothSlotKey.Uniform]}
            onClick={() => toggleSlotFilter(ClothingBoothSlotKey.Uniform)}>
            Uniform
          </Button.Checkbox>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
