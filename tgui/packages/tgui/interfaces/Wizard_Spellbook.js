/**
 * @file
 * @copyright 2024
 * @author IPingu (https://github.com/IPling)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Button, Collapsible, Divider, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';

// If I wanna color the categories, but probably gonna be scrapped
const category_coloring = (spell_category) => {
  switch (spell_category) {
    case "Enchantment":
      return "purple";
    case "Equipment":
      return "yellow";
    case "Offensive":
      return "red";
    case "Defensive":
      return "blue";
    case "Utility":
      return "green";
    case "Miscellaneous":
      return "grey";
  }
};

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
        <Section title={owner_name+"'s Spellbook "}>
          {"Spell slots remaining: "+spell_slots}
          <Divider />
          {spell_categories.map((category) => (
            <SpellCategory category={category} key={category} />
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
    <Collapsible title={category} textColor={category_coloring(category)} bold>
      <Stack vertical textColor={category_coloring(category)}>
        {spells.map((spell) => (
          <Spell spell={spell} category={category} key={spell} />
        ))}
      </Stack>
    </Collapsible>
  );
};

const Spell = (props, context) => {
  const { data } = useBackend(context);
  const { spellbook_contents } = data;
  const { spell, category } = props;

  let spell_contents = [];

  for (let spell_data in spellbook_contents[category][spell]) {
    spell_contents.push(spellbook_contents[category][spell][spell_data]);
  }

  return (
    <Stack.Item>
      <Section
        title={spell+" - cost: "+spell_contents[1]}
        buttons={<Button>{"Purchase"}</Button>}
      >
        <LabeledList>
          <LabeledList.Item label={"Description"}>
            {spell_contents[0]}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

