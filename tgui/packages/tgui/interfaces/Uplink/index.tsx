/**
 * @file
 * @copyright 2024
 * @author IPingu (https://github.com/IPling)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useState } from 'react';
import { Box, Flex, Input, Section, Stack, Tabs } from 'tgui-core/components';
import { capitalizeAll, pluralize } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { ItemEntry } from './ItemEntry';
import { PlaceholderItem } from './PlaceholderItem';
import type { UplinkData } from './type';

const SIDEBAR_WIDTH = '160px';

export const Uplink = () => {
  const { data } = useBackend<UplinkData>();
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

  const { item_entries, currency_amount, currency_name, vr } = data;
  const isVr = !!vr;
  const lowerSearchQuery = searchQuery.toLocaleLowerCase();

  const itemCategories = Object.keys(item_entries);
  const filteredItems = Object.entries(item_entries)
    .filter(([category]) => allFiltersApplied || categoryFilters[category])
    .flatMap(([_category, items]) => items)
    .filter((item) => item.name.toLocaleLowerCase().includes(lowerSearchQuery))
    .sort((a, b) => a.name.localeCompare(b.name));

  return (
    <Window theme={data.theme} title={data.title} height={600} width={720}>
      <Flex>
        <Flex.Item style={{ width: SIDEBAR_WIDTH }}>
          <Stack vertical ml={1} mt={1}>
            <Stack.Item>
              <Section textAlign="center">
                <Box
                  fontSize={2}
                  color={currency_amount === 0 ? 'bad' : undefined}
                >
                  {currency_amount}
                </Box>
                <Box>
                  {pluralize(capitalizeAll(currency_name), currency_amount)}{' '}
                  remaining
                </Box>
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
                  {itemCategories.map((itemCategory) => (
                    <Tabs.Tab
                      key={itemCategory}
                      align="right"
                      selected={!!categoryFilters[itemCategory]}
                      onClick={() =>
                        setCategoryFilters({ [itemCategory]: true })
                      }
                    >
                      {itemCategory}
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
              {filteredItems.length === 0 ? (
                <PlaceholderItem onClearClick={clearFilters} />
              ) : (
                filteredItems.map((item) => (
                  <ItemEntry
                    key={item.name}
                    item={item}
                    isVr={isVr}
                    currency_amount={currency_amount}
                    currency_name={currency_name}
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
