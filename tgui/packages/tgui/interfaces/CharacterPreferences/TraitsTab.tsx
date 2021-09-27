import { toTitleCase } from 'common/string';
import { useBackend } from '../../backend';
import { BlockQuote, Box, Collapsible, Divider, Flex, Section, Stack } from '../../components';
import { CharacterPreferencesData, CharacterPreferencesTrait } from './type';

export const TraitsTab = (_props, context) => {
  const { act, data } = useBackend<CharacterPreferencesData>(context);

  const traitsByCategory: Record<string, CharacterPreferencesTrait[]> = {};

  for (const trait of data.traitsAvailabe) {
    const category = trait.category ?? 'uncategorized';

    if (!traitsByCategory[category]) {
      traitsByCategory[category] = [];
    }

    traitsByCategory[category].push(trait);
  }

  return (
    <Section title="Traits" fill>
      <Box>test</Box>

      <Divider />

      <Stack fill>
        <Stack.Item grow>
          <Section title="Available" fill scrollable>
            {Object.entries(traitsByCategory).map(([category, traits]) => (
              <TraitList key={category} category={category} traits={traits.filter((trait) => !trait.selected)} />
            ))}
          </Section>
        </Stack.Item>
        <Divider vertical hidden />
        <Stack.Item grow>
          <Section title="Selected" fill scrollable>
            {Object.entries(traitsByCategory).map(([category, traits]) => (
              <TraitList key={category} category={category} traits={traits.filter((trait) => trait.selected)} />
            ))}
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

type TraitListProps = {
  category: string;
  traits: CharacterPreferencesTrait[];
};

const TraitList = (props: TraitListProps) => {
  const { category, traits } = props;

  if (traits.length === 0) {
    return null;
  }

  return (
    <Collapsible title={toTitleCase(category)} open>
      {traits.map((trait) => (
        <Trait key={trait.id} {...trait} />
      ))}
    </Collapsible>
  );
};

const Trait = (props: CharacterPreferencesTrait) => {
  const { name, desc, points } = props;

  return (
    <Box mb={1}>
      <Flex justify="space-between">
        <Box mb={0.5}>{name}</Box>
        <Box mb={0.5} color={points < 0 ? 'bad' : points > 0 ? 'good' : 'default'}>
          {points}
        </Box>
      </Flex>
      <BlockQuote>{desc}</BlockQuote>
    </Box>
  );
};
