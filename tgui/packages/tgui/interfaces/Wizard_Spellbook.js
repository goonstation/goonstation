/**
 * @file
 * @copyright 2024
 * @author IPingu (https://github.com/IPling)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { Window } from '../layouts';



const Spell = (props, context) => {
  const { data } = useBackend(context);
  const { Spell_Data } = data;
  const { spell } = props;

  return (
    <Stack vertical>
      <Stack.Item>
        {spell}
      </Stack.Item>
    </Stack>
  );
};

const SpellCategory = (props, context) => {
  const { data } = useBackend(context);
  const { Spell_Data } = data;
  const { category } = props;

  let spells = [];
  for (let spell_name in Spell_Data[category]) {
    spells.push(spell_name);
  }
  return (
    <Section title={category}>
      {spells.map((s) => (<Spell spell={s} key={s} />))}
    </Section>
  );
};

export const Wizard_Spellbook = (props, context) => {
  const { data } = useBackend(context);
  const {
    Spell_Data,
  } = data;

  let spell_categories = [];
  for (let spell_category in Spell_Data) {
    spell_categories.push(spell_category);
  }

  return (
    <Window>
      <Window.Content>
        {spell_categories.map((c) => (<SpellCategory category={c} key={c} />))}
      </Window.Content>
    </Window>
  );
};
