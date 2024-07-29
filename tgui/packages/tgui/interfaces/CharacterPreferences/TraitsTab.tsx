/**
 * @file
 * @copyright 2022
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { toTitleCase } from 'common/string';
import { Fragment, useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Divider,
  Image,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { CharacterPreferencesData, CharacterPreferencesTrait } from './type';

const sortTraits = (
  a: CharacterPreferencesTrait,
  b: CharacterPreferencesTrait,
) => a.name.localeCompare(b.name, 'en', { sensitivity: 'base' });

export const TraitsTab = () => {
  const { act, data } = useBackend<CharacterPreferencesData>();
  const [filterAvailable, setFilterAvailable] = useState(false);

  const traitsByCategory: Record<string, CharacterPreferencesTrait[]> = {};

  const traits: CharacterPreferencesTrait[] = data.traitsAvailable.map(
    (trait) => ({
      ...trait,
      ...data.traitsData[trait.id],
    }),
  );

  for (const trait of traits) {
    const categories =
      trait.category && trait.category.length > 0
        ? trait.category
        : ['uncategorized'];

    for (const category of categories) {
      if (!traitsByCategory[category]) {
        traitsByCategory[category] = [];
      }

      traitsByCategory[category].push(trait);
    }
  }

  let traitCategories = Object.keys(traitsByCategory).sort();
  // Uncategorized always goes last.
  if (traitCategories.includes('uncategorized')) {
    traitCategories = [
      ...traitCategories.filter((c) => c !== 'uncategorized'),
      'uncategorized',
    ];
  }

  const selectedAmount = data.traitsAvailable.filter(
    (trait) => trait.selected,
  ).length;

  return (
    <Section fill>
      <Stack vertical fill>
        <Stack.Item>
          <Box>
            {'Available points: '}
            <Box as="span" color={data.traitsPointsTotal > 0 ? 'good' : 'bad'}>
              {data.traitsPointsTotal}
            </Box>
          </Box>
          <Divider />
        </Stack.Item>
        <Stack.Item grow>
          <Stack fill>
            <Stack.Item grow basis={0}>
              <Section
                title="Available"
                fill
                scrollable
                buttons={
                  <Button.Checkbox
                    checked={filterAvailable}
                    onClick={() => setFilterAvailable(!filterAvailable)}
                  >
                    Filter available
                  </Button.Checkbox>
                }
              >
                {traitCategories.map((category) => {
                  const traits = traitsByCategory[category];

                  return (
                    <TraitCategoryList
                      key={category}
                      category={category}
                      traits={traits
                        .filter((trait) => !trait.selected)
                        .filter((trait) =>
                          filterAvailable ? trait.available : true,
                        )
                        .sort(sortTraits)}
                    />
                  );
                })}
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Divider vertical />
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <Section
                title={`Selected (${selectedAmount}${data.traitsMax !== Infinity ? `/${data.traitsMax}` : ''})`}
                fill
                scrollable
                buttons={
                  <Button onClick={() => act('reset-traits')}>
                    Reset traits
                  </Button>
                }
              >
                {traitCategories.map((category) => {
                  const traits = traitsByCategory[category];

                  return (
                    <TraitCategoryList
                      key={category}
                      category={category}
                      traits={traits
                        .filter((trait) => trait.selected)
                        .sort(sortTraits)}
                    />
                  );
                })}
              </Section>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

type TraitCategoryListProps = {
  category: string;
  traits: CharacterPreferencesTrait[];
};

const TraitCategoryList = (props: TraitCategoryListProps, context) => {
  const { category, traits } = props;

  if (traits.length === 0) {
    return null;
  }

  return (
    <Collapsible title={toTitleCase(category)} open>
      {traits.map((trait, index) => (
        <Fragment key={trait.id}>
          {index !== 0 && <Divider />}
          <Trait {...trait} />
        </Fragment>
      ))}
    </Collapsible>
  );
};

const Trait = (props: CharacterPreferencesTrait) => {
  const { id, name, desc, points, selected, available, img } = props;
  const { act } = useBackend<CharacterPreferencesData>();
  return (
    <Stack>
      <Stack.Item>
        <Image
          width="32px"
          height="32px"
          src={`data:image/png;base64,${img}`}
          backgroundColor="transparent"
        />
      </Stack.Item>
      <Stack.Item grow={1}>
        <Stack align="center" mb={1}>
          <Stack.Item grow>
            {`${name} `}
            <Box
              as="span"
              color={points < 0 ? 'bad' : points > 0 ? 'good' : 'label'}
            >
              ({points > 0 ? '+' : ''}
              {points})
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Button
              disabled={!available}
              icon={selected ? 'minus' : 'plus'}
              onClick={() =>
                act(selected ? 'unselect-trait' : 'select-trait', { id })
              }
            >
              {selected ? 'Remove' : 'Add'}
            </Button>
          </Stack.Item>
        </Stack>

        <BlockQuote>{desc}</BlockQuote>
      </Stack.Item>
    </Stack>
  );
};
