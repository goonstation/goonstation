/**
 * @file
 * @copyright 2024
 * @author IPingu (https://github.com/IPling)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useState } from 'react';
import { Box, Flex, Input, Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { PlaceholderItem } from './PlaceholderItem';
import { SpellItem } from './SpellItem';
import type { WizardSpellbookData } from './type';

const SIDEBAR_WIDTH = '160px';

export const WizardSpellbook = () => {
  const { data } = useBackend<WizardSpellbookData>();
  const [searchQuery, setSearchQuery] = useState('');
  const [categoryFilters, setCategoryFilters] = useState<
    Record<string, boolean>
  >({});
  const clearFilters = () => {
    setSearchQuery('');
    setCategoryFilters({});
  };
  const allFiltersApplied =
    Object.values(categoryFilters).length === 0 ||
    Object.values(categoryFilters).every((filter) => !filter);

  const { spellbook_contents, spell_slots, owner_name, vr } = data;
  const isVr = !!vr;
  const lowerSearchQuery = searchQuery.toLocaleLowerCase();

  const spellCategories = Object.keys(spellbook_contents);
  const filteredSpells = Object.entries(spellbook_contents)
    .filter(([category]) => allFiltersApplied || categoryFilters[category])
    .flatMap(([_category, spells]) => spells)
    .filter((spell) =>
      spell.name.toLocaleLowerCase().includes(lowerSearchQuery),
    )
    .sort((a, b) => a.name.localeCompare(b.name));

  return (
    <Window
      title={`${owner_name || 'Wizard'}'s Spellbook`}
      height={600}
      width={720}
    >
      <Flex>
        <Flex.Item style={{ width: SIDEBAR_WIDTH }}>
          <Stack vertical ml={1} mt={1}>
            <Stack.Item>
              <Section textAlign="center">
                <Box fontSize={2} color={spell_slots === 0 ? 'bad' : undefined}>
                  {spell_slots}
                </Box>
                <Box>Spell slots remaining</Box>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section>
                <Input
                  value={searchQuery}
                  placeholder="Search by name"
                  width="100%"
                  autoSelect
                  onChange={(value: string) => setSearchQuery(value)}
                />
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section fitted>
                <Tabs vertical>
                  <Tabs.Tab
                    align="right"
                    selected={allFiltersApplied}
                    onClick={() => setCategoryFilters({})}
                  >
                    All
                  </Tabs.Tab>
                  {spellCategories.map((spellCategory) => (
                    <Tabs.Tab
                      key={spellCategory}
                      align="right"
                      selected={!!categoryFilters[spellCategory]}
                      onClick={() =>
                        setCategoryFilters({ [spellCategory]: true })
                      }
                    >
                      {spellCategory}
                    </Tabs.Tab>
                  ))}
                </Tabs>
              </Section>
            </Stack.Item>
          </Stack>
        </Flex.Item>
        <Flex.Item>
          <Window.Content scrollable ml={SIDEBAR_WIDTH}>
            <Stack vertical>
              {filteredSpells.length === 0 ? (
                <PlaceholderItem onClearClick={clearFilters} />
              ) : (
                filteredSpells.map((spell) => (
                  <SpellItem
                    key={spell.name}
                    spell={spell}
                    isVr={isVr}
                    spellSlots={spell_slots}
                  />
                ))
              )}
            </Stack>
          </Window.Content>
        </Flex.Item>
      </Flex>
    </Window>
  );
};
