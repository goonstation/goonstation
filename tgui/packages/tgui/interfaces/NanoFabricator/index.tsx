import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  Image,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Slider,
  Stack,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { ItemButton } from '../../components/goonstation/ItemButton';
import { Window } from '../../layouts';
import {
  NanoFabricatorData,
  NanoPartOptionData,
  NanoRecipeData,
  NanoSelectedRecipeData,
  NanoSelectingPartData,
  NanoStorageData,
} from './type';

export const NanoFabricator = () => {
  const { act, data } = useBackend<NanoFabricatorData>();
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState('All');
  const { categories = [], recipes = [] } = data;

  const searchText = search.toLocaleLowerCase();
  const visibleRecipes = recipes.filter(
    (recipe) =>
      (category === 'All' || recipe.category === category) &&
      (!searchText ||
        recipe.name.toLocaleLowerCase().includes(searchText) ||
        recipe.description.toLocaleLowerCase().includes(searchText)),
  );

  return (
    <Window title="Nano-fabricator" width={720} height={640}>
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
                <Stack.Item basis="150px">
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

interface BlueprintCatalogProps {
  onSelectRecipe: (ref: string) => void;
  recipes: NanoRecipeData[];
}

const BlueprintCatalog = (props: BlueprintCatalogProps) => {
  const { onSelectRecipe, recipes } = props;

  return (
    <Section fill scrollable title={`Blueprints (${recipes.length})`}>
      <Stack vertical g={0}>
        {recipes.map((recipe) => (
          <Stack.Item key={recipe.ref}>
            <ItemButton
              image={recipe.img}
              name={recipe.name}
              onMainButtonClick={() => onSelectRecipe(recipe.ref)}
              sideButton1={{
                icon: 'info',
                tooltip: recipe.description,
                disabled: false,
              }}
              sideButton2={{
                icon: 'gear',
                tooltip: <RecipeRequirementsTooltip recipe={recipe} />,
                disabled: false,
              }}
            />
          </Stack.Item>
        ))}
        {!recipes.length && (
          <Stack.Item>
            <NoticeBox>No blueprints match the current filters.</NoticeBox>
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};

const RecipeRequirementsTooltip = (props: { recipe: NanoRecipeData }) => {
  const { recipe } = props;

  return (
    <Section title="Components">
      <LabeledList>
        {recipe.parts.map((part) => (
          <LabeledList.Item
            key={part.ref}
            label={`${part.part_name || 'Component'}${part.optional ? ' (optional)' : ''}`}
            labelColor={part.optional ? 'label' : undefined}
            textAlign="right"
          >
            {part.amount} unit{part.amount === 1 ? '' : 's'}
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

interface RecipeDetailProps {
  partOptions: NanoPartOptionData[];
  selectedRecipe: NanoSelectedRecipeData | null;
  selectingPart: NanoSelectingPartData | null;
}

const RecipeDetail = (props: RecipeDetailProps) => {
  const { act } = useBackend<NanoFabricatorData>();
  const { partOptions, selectedRecipe, selectingPart } = props;
  const [buildAmount, setBuildAmount] = useState(1);

  useEffect(() => {
    setBuildAmount(1);
  }, [selectedRecipe?.ref]);

  if (!selectedRecipe) {
    return (
      <Section fill title="Recipe details">
        <NoticeBox>Select a blueprint to configure its materials.</NoticeBox>
      </Section>
    );
  }

  const maxBuildAmount = Math.max(selectedRecipe.maxAmount, 1);
  const selectedBuildAmount = Math.min(buildAmount, maxBuildAmount);

  return (
    <Section fill scrollable title="Recipe details">
      <Stack vertical>
        <Stack.Item>
          <Stack align="center">
            <Stack.Item basis="64px">
              {selectedRecipe.img && (
                <Image
                  src={selectedRecipe.img}
                  height="64px"
                  width="64px"
                  backgroundColor="rgba(0,0,0,0.2)"
                />
              )}
            </Stack.Item>
            <Stack.Item grow>
              <Box bold fontSize={1.2}>
                {selectedRecipe.name}
              </Box>
              <Box color="label">{selectedRecipe.description}</Box>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Section title="Components">
            <Stack vertical>
              {selectedRecipe.parts.map((part) => (
                <Stack.Item key={part.ref}>
                  <Button
                    fluid
                    selected={part.ref === selectingPart?.ref}
                    onClick={() => act('select_part', { ref: part.ref })}
                  >
                    <Stack align="center">
                      <Stack.Item grow>
                        <Box bold>
                          {part.part_name || part.name}
                          {part.optional ? ' (optional)' : ''}
                        </Box>
                        <Box color="label">
                          {part.amount} x {part.name}
                        </Box>
                      </Stack.Item>
                      <Stack.Item textAlign="right">
                        {part.assigned ? (
                          <Stack align="center">
                            <Stack.Item basis="32px">
                              {part.assigned.img && (
                                <Image
                                  src={part.assigned.img}
                                  height="32px"
                                  width="32px"
                                />
                              )}
                            </Stack.Item>
                            <Stack.Item>
                              <Box
                                color={
                                  part.assigned.amount < part.amount
                                    ? 'bad'
                                    : undefined
                                }
                              >
                                {part.assigned.name}
                              </Box>
                              <Box
                                color={
                                  part.assigned.amount < part.amount
                                    ? 'bad'
                                    : 'label'
                                }
                              >
                                {part.assigned.amount < part.amount
                                  ? 'Insufficient amount'
                                  : `${part.assigned.amount} available`}
                              </Box>
                            </Stack.Item>
                          </Stack>
                        ) : part.optional ? (
                          <Box color="label">Not selected</Box>
                        ) : (
                          <Tooltip
                            content="Select a material for this required slot"
                            position="bottom"
                          >
                            <Icon name="spinner" spin={1} />
                          </Tooltip>
                        )}
                      </Stack.Item>
                    </Stack>
                  </Button>
                </Stack.Item>
              ))}
            </Stack>
          </Section>
        </Stack.Item>
        {selectingPart && (
          <Stack.Item>
            <Section
              title={`Choose ${selectingPart.part_name || selectingPart.name}`}
              buttons={
                <Button icon="times" onClick={() => act('cancel_part')}>
                  Close
                </Button>
              }
            >
              {partOptions.length ? (
                <Stack vertical>
                  {partOptions.map((option) => (
                    <Stack.Item key={option.ref}>
                      <Button
                        fluid
                        disabled={option.insufficient}
                        color={option.insufficient ? 'bad' : undefined}
                        onClick={() => act('choose_part', { ref: option.ref })}
                      >
                        <Stack>
                          <Stack.Item basis="32px">
                            {option.img && (
                              <Image
                                src={option.img}
                                height="32px"
                                width="32px"
                              />
                            )}
                          </Stack.Item>
                          <Stack.Item grow>{option.name}</Stack.Item>
                          <Stack.Item>
                            {option.insufficient
                              ? 'Insufficient amount'
                              : `${option.amount} available`}
                          </Stack.Item>
                        </Stack>
                      </Button>
                    </Stack.Item>
                  ))}
                </Stack>
              ) : (
                <NoticeBox>
                  No valid components are available for this slot.
                </NoticeBox>
              )}
            </Section>
          </Stack.Item>
        )}
        <Stack.Item>
          <Stack align="center">
            <Stack.Item grow>
              {selectedRecipe.complete && selectedRecipe.maxAmount > 0 ? (
                <Box color="good">
                  Ready to build up to {selectedRecipe.maxAmount}.
                </Box>
              ) : (
                <Box color="label">Assign all required materials to build.</Box>
              )}
            </Stack.Item>
            <Stack.Item grow>
              <Slider
                value={selectedBuildAmount}
                minValue={1}
                maxValue={maxBuildAmount}
                step={1}
                format={(value) => `${value}x`}
                disabled={
                  !selectedRecipe.complete || selectedRecipe.maxAmount <= 0
                }
                onChange={(_event, value) => setBuildAmount(value)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="cogs"
                disabled={
                  !selectedRecipe.complete || selectedRecipe.maxAmount <= 0
                }
                onClick={() =>
                  act('build', {
                    amount: selectedBuildAmount,
                  })
                }
              >
                Build
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const StorageView = (props: { storage: NanoStorageData[] }) => {
  const { act } = useBackend<NanoFabricatorData>();
  const { storage } = props;

  return (
    <Section fill scrollable title="Storage">
      {storage.length ? (
        <Stack vertical>
          {storage.map((item) => (
            <Stack.Item key={item.ref}>
              <Stack align="center">
                <Stack.Item basis="36px">
                  {item.img && (
                    <Image src={item.img} height="36px" width="36px" />
                  )}
                </Stack.Item>
                <Stack.Item grow>
                  <Box>{item.name}</Box>
                  <Box color="label">{item.amount} available</Box>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    width={2}
                    tooltip="Eject"
                    onClick={() => act('eject', { ref: item.ref })}
                  >
                    <Stack fill align="center" justify="center">
                      <Stack.Item>
                        <Icon name="sign-out" lineHeight={1} />
                      </Stack.Item>
                    </Stack>
                  </Button>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          ))}
        </Stack>
      ) : (
        <NoticeBox>No objects found in storage.</NoticeBox>
      )}
    </Section>
  );
};
