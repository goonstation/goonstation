import { toTitleCase } from 'common/string';
import { useBackend, useLocalState } from '../../backend';
import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Divider,
  Flex,
  Input,
  LabeledList,
  Section,
  Stack,
} from '../../components';
import { CharacterPreferencesData, CharacterPreferencesTrait } from './type';
import { Fragment } from 'inferno';
import { ButtonCheckbox } from '../../components/Button';

export const TraitsTab = (_props, context) => {
  const { act, data } = useBackend<CharacterPreferencesData>(context);
  const [filterAvailable, setFilterAvailable] = useLocalState(context, `filter-available`, false);

  const traitsByCategory: Record<string, CharacterPreferencesTrait[]> = {};

  for (const trait of data.traitsAvailable) {
    const category = trait.category ?? 'uncategorized';

    if (!traitsByCategory[category]) {
      traitsByCategory[category] = [];
    }

    traitsByCategory[category].push(trait);
  }

  const selectedAmount = data.traitsAvailable.filter((trait) => trait.selected).length;

  return (
    <Section fill>
      <Stack vertical fill>
        <Stack.Item>
          <Box>
            Available points:{' '}
            <Box as="span" color={data.traitsPointsTotal > 0 ? 'good' : 'bad'}>
              {data.traitsPointsTotal}
            </Box>
          </Box>
          <Box textColor="label">You can only select 1 trait from a single category.</Box>
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
                  <ButtonCheckbox checked={filterAvailable} onClick={() => setFilterAvailable(!filterAvailable)}>
                    Filter available
                  </ButtonCheckbox>
                }>
                {Object.entries(traitsByCategory).map(([category, traits]) => (
                  <TraitCategoryList
                    key={category}
                    category={category}
                    traits={traits
                      .filter((trait) => !trait.selected)
                      .filter((trait) => (filterAvailable ? trait.available : true))}
                  />
                ))}
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Divider vertical />
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <Section
                title={`Selected (${selectedAmount}/${data.traitsMax})`}
                fill
                scrollable
                buttons={<Button onClick={() => act('reset-traits')}>Reset traits</Button>}>
                {Object.entries(traitsByCategory).map(([category, traits]) => (
                  <TraitCategoryList
                    key={category}
                    category={category}
                    traits={traits.filter((trait) => trait.selected)}
                  />
                ))}
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

const Trait = (props: CharacterPreferencesTrait, context) => {
  const { act } = useBackend<CharacterPreferencesData>(context);

  const { id, name, desc, points, selected, available } = props;

  return (
    <Stack vertical>
      <Stack.Item>
        <Stack justify="space-between" align="center">
          <Stack.Item>
            {name}{' '}
            <Box as="span" color={points < 0 ? 'bad' : points > 0 ? 'good' : 'label'}>
              ({points})
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Button
              disabled={!available}
              icon={selected ? 'minus' : 'plus'}
              onClick={() => act(selected ? 'unselect-trait' : 'select-trait', { id })}>
              {selected ? 'Remove' : 'Add'}
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack>
        <Stack.Item grow>
          <BlockQuote>{desc}</BlockQuote>
        </Stack.Item>
      </Stack>
    </Stack>
  );
};
