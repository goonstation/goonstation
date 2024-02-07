/**
 * @file
 * @copyright 2024
 * @author IPingu (https://github.com/IPling)
 * @license ISC
 */

import { useBackend } from '../backend';
// import { Text } from '../components';
import { Window } from '../layouts';

export const Wizard_Spellbook = (props, context) => {
  const { data } = useBackend(context);
  const {
    Spell_Data,
  } = data;

  return (
    <Window>
      <Window.Content>
        {Spell_Data === null ? "null": "huh?"}
        {Spell_Data === undefined ? "undefined": "huh???"}
        {typeof(Spell_Data)}
        {Spell_Data}
      </Window.Content>
    </Window>
  );
};

// {Spell_Data.map((categories) => <Text key={categories.name}>{categories.spell}</Text>)}
// {Spell_Data === null ? "null": "huh?"}
// {Spell_Data === undefined ? "undefined": "huh???"}
// typeof(Spell_Data)}
