import { useBackend, useLocalState } from '../../backend';
import { Dropdown, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { ClothingItemList } from './ClothingItemList';
import { CharacterPreview } from './CharacterPreview';
import { PurchaseInfo } from './PurchaseInfo';
import type { ClothingBoothData } from './type';

export const ClothingBooth = (_, context) => {
  const { data } = useBackend<ClothingBoothData>(context);
  const categories = data.clothingBoothCategories ?? [];

  const [selectedCategory, selectCategory] = useLocalState(context, 'selectedCategory', categories[0]);
  const { items } = selectedCategory;
  const handleSelectCategory = (value) =>
    selectCategory(categories[categories.findIndex((category) => category.category === value)]);

  return (
    <Window title={data.name} width={300} height={500}>
      <Window.Content>
        <Stack fill vertical>
          {/* Topmost section, containing the cash balance and category dropdown. */}
          <Stack.Item>
            <Section fill>
              <Stack fill align="center" justify="space-between">
                <Stack.Item bold>Cash: {data.money}⪽</Stack.Item>
                <Stack.Item>
                  <Dropdown
                    className="clothingbooth__dropdown"
                    options={categories.map((category) => category.category)}
                    selected={selectedCategory.category}
                    onSelected={handleSelectCategory}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          {/* Clothing booth item list */}
          <Stack.Item grow={1}>
            <Stack fill vertical>
              <Stack.Item grow={1}>
                <Section fill scrollable>
                  <ClothingItemList items={items} />
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          {/* Character rendering and purchase button. */}
          <Stack.Item>
            <Stack>
              <Stack.Item align="center">
                <Section fill>
                  <CharacterPreview />
                </Section>
              </Stack.Item>
              <Stack.Item grow={1}>
                <Section fill title="Purchase Info">
                  <Stack fill vertical justify="space-around">
                    <Stack.Item>
                      <PurchaseInfo />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
