/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import {
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';

import { ItemButton } from '../../../components/goonstation/ItemButton';
import type { NanoRecipeData } from '../type';

interface BlueprintCatalogProps {
  onSelectRecipe: (ref: string) => void;
  recipes: NanoRecipeData[];
}

export const BlueprintCatalog = (props: BlueprintCatalogProps) => {
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
            label={
              <Stack align="center">
                {!!part.optional && (
                  <Stack.Item>
                    <Tooltip content="Optional component">
                      <Icon name="asterisk" />
                    </Tooltip>
                  </Stack.Item>
                )}
                <Stack.Item>{part.part_name || 'Component'}</Stack.Item>
              </Stack>
            }
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
