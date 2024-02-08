/**
 * @file
 * @copyright 2024
 * @author IPingu (https://github.com/IPling)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Collapsible, Divider, Section, Stack } from '../components';
import { Window } from '../layouts';

export const Wizard_Spellbook = (props, context) => {
  const { data } = useBackend(context);
  const {
    spellbook_contents,
    owner_name,
    spell_slots,
  } = data;

  let spell_categories = [];
  for (let spell_category in spellbook_contents) {
    spell_categories.push(spell_category);
  }

  return (
    <Window
      title={"Wizard Spellbook"}
      theme={"ntos"}
      maxWidth={300}
      maxHeight={770}
    >
      <Window.Content scrollable>
        <Section title={owner_name+"'s Spellbook"}>
          {"Spell slots remaining:"+spell_slots}
          <Divider />
          {spell_categories.map((cat_section) => (
            <SpellCategory category={cat_section} key={cat_section} />
          ))}
        </Section>
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
    <Collapsible title={category}>
      {spells.map((spell) => (
        <Spell spell={spell} key={spell} />
      ))}
    </Collapsible>
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
