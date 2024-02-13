/**
 * @file
 * @copyright 2024
 * @author IPingu (https://github.com/IPling)
 * @license ISC
 */

import { useBackend, useSharedState } from '../backend';
import { Box, Button, Collapsible, Dimmer, LabeledList, Section, Stack } from '../components';
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
      fontSize={2}
      title={"Wizard Spellbook"}
      theme={"ntos"}
      width={500}
      height={600}
    >
      <Window.Content>
        <Section title={owner_name+"'s Spellbook "}>
          {"Spell slots remaining: "+spell_slots}
        </Section>
      </Window.Content>
      <Window.Content mt={11} scrollable>
        <Section>
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
      <Stack vertical>
        {spells.map((spell) => (
          <Spell spell={spell} category={category} key={spell} />
        ))}
      </Stack>
    </Collapsible>
  );
};

const If_Purchased_Text = (purchased, cost, spell_slots) => {
  if (purchased) {
    return "Spell purchased";
  } else if (cost > spell_slots) {
    return "Not enough spell slots";
  } else {
    return "Purchase";
  }
};

const Spell = (props, context) => {
  const { data, act } = useBackend(context);
  const { spellbook_contents, purchased_spells, spell_slots, vr } = data;
  const { spell, category } = props;

  let spell_contents = []; // desc, cost, cooldown, vr_allowed
  const [purchased, setPurchased] = useSharedState(context, spell, false);

  for (let spell_data in spellbook_contents[category][spell]) {
    spell_contents.push(spellbook_contents[category][spell][spell_data]);
  }

  return (
    <Stack.Item>
      <Section>
        {(vr === 1) && (spell_contents[3] === 0) && (
          <Dimmer>
            <Box fontSize={1.5} backgroundColor={"#384e68"} p={2}>
              spell unavailable in VR
            </Box>
          </Dimmer>
        )}
        <Section
          title={spell}
          buttons={
            <Button
              backgroundColor={"green"}
              disabled={spell_slots < spell_contents[1] || purchased}
              onClick={() => { setPurchased(true); act("buyspell", { spell: spell }); }}
            >
              {If_Purchased_Text(purchased, spell_contents[1], spell_slots)}
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label={"Cost"}>
              {spell_contents[1]}
            </LabeledList.Item>
            {spell_contents[2] !== null && (
              <LabeledList.Item label={"Cooldown"}>
                {spell_contents[2]/10+" seconds"}
              </LabeledList.Item>
            )}
            <LabeledList.Item label={"Description"}>
              {spell_contents[0]}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Section>
    </Stack.Item>
  );
};

