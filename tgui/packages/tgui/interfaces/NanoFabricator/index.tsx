/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { useState } from 'react';
import { Button, Dropdown, Input, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { BlueprintCatalog } from './components/BlueprintCatalog';
import { RecipeDetail } from './components/RecipeDetail';
import { StorageView } from './components/StorageView';
import type { NanoFabricatorData } from './type';

export const NanoFabricator = () => {
  const { act, data } = useBackend<NanoFabricatorData>();
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState('All');
  const { categories = [], recipes = [] } = data;

  const searchText = search.toLowerCase();
  const visibleRecipes = recipes.filter(
    (recipe) =>
      (category === 'All' || recipe.category === category) &&
      (!searchText || recipe.name.toLowerCase().includes(searchText)),
  );

  return (
    <Window title="Nano-fabricator" width={855} height={640}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section>
              <Stack align="center">
                <Stack.Item grow>
                  <Input
                    fluid
                    value={search}
                    placeholder="Search..."
                    onChange={setSearch}
                  />
                </Stack.Item>
                <Stack.Item width="150px">
                  <Dropdown
                    fluid
                    options={['All', ...categories]}
                    selected={category}
                    onSelected={setCategory}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button.Checkbox
                    checked={data.outputInternal}
                    onClick={() => act('toggle_output')}
                    tooltip="When enabled, fabricated items are placed inside this machine."
                  >
                    Internal output
                  </Button.Checkbox>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item width="20em">
                <Stack fill vertical>
                  <Stack.Item grow>
                    <BlueprintCatalog
                      recipes={visibleRecipes}
                      onSelectRecipe={(ref) => act('select_recipe', { ref })}
                    />
                  </Stack.Item>
                  <Stack.Item basis="34%">
                    <StorageView storage={data.storage} />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item grow>
                <RecipeDetail
                  partOptions={data.partOptions}
                  selectedRecipe={data.selectedRecipe}
                  selectingPart={data.selectingPart}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
