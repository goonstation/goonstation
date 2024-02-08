/**
 * @file
 * @copyright 2024
 * @author IPingu (https://github.com/IPling)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { Window } from '../layouts';

export const Wizard_Spellbook = (props, context) => {
  const { data } = useBackend(context);
  const { spellbook_contents } = data;

  let spell_categories = [];
  for (let spell_category in spellbook_contents) {
    spell_categories.push(spell_category);
  }

  return (
    <Window>
      <Window.Content>
        {spell_categories.map((cat_section) => ( // Categories, not literal cats
          <SpellCategory category={cat_section} key={cat_section} />
        ))}
      </Window.Content>
    </Window>
  );
};

const SpellCategory = (props, context) => {
  const { data } = useBackend(context);
  const { spellbook_contents } = data;
  const { category } = props;

  let spells = [];
  for (let spell_name in spellbook_contents[category]) {
    spells.push(spell_name);
  }
  return (
    <Section title={category}>
      {spells.map((spell) => (
        <Spell spell={spell} key={spell} />
      ))}
    </Section>
  );
};

const Spell = (props, context) => {
  const { spell } = props;

  return (
    <Stack vertical>
      <Stack.Item>
        {spell}
      </Stack.Item>
    </Stack>
  );
};
