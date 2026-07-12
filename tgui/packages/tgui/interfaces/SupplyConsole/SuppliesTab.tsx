/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */

import {
  BlockQuote,
  Box,
  Button,
  Input,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../../backend';
import { formatMoney } from '../../format';
import { SupplyConsoleData } from './type';

export const SupplyConsoleSuppliesTab = () => {
  const { data } = useBackend<SupplyConsoleData>();
  const [supply_tab, setSupplyTab] = useSharedState('supplytab', 'all');
  const [suppliesTabSearchQuery, setSearchQuery] = useSharedState(
    'suppliesTabSearchQuery',
    '',
  );
  const filteredEntries = data.supply_entries
    .filter((entry) => supply_tab === 'all' || entry.category === supply_tab)
    .filter((entry) =>
      (entry.name + entry.desc)
        .toLocaleLowerCase()
        .includes(suppliesTabSearchQuery.toLocaleLowerCase()),
    );
  return (
    <Section title="Place Order" fill>
      <Stack vertical fill>
        <Stack.Item pb="5px">
          <Input
            fluid
            value={suppliesTabSearchQuery}
            onChange={setSearchQuery}
            placeholder="Filter Packages"
          />
        </Stack.Item>
        <Stack.Item>
          <Tabs scrollable>
            <Tabs.Tab
              selected={supply_tab === 'all'}
              onClick={() => setSupplyTab('all')}
            >
              All Entries
            </Tabs.Tab>
            {data.supply_categories.map((category, index) => (
              <Tabs.Tab
                key={index}
                selected={supply_tab === category}
                onClick={() => setSupplyTab(category)}
              >
                {category}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
        <Stack.Item grow>
          <Section scrollable fill noTopPadding>
            <Table>
              {filteredEntries.map((entry, index) => (
                <SupplyEntry entry={entry} key={index} />
              ))}
            </Table>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const SupplyEntry = (props) => {
  const { data, act } = useBackend<SupplyConsoleData>();
  const { entry } = props;
  return (
    <Table.Row className="candystripe">
      <Table.Cell py="5px">
        <Box mb="5px">
          <b>{entry.name}</b>
        </Box>
        <BlockQuote>{entry.desc}</BlockQuote>
      </Table.Cell>
      <Table.Cell py="5px" align="right">
        <Stack vertical>
          <Stack.Item>
            <Button
              icon="cart-shopping"
              disabled={data.shipping_budget < entry.cost}
              onClick={() =>
                act('place_order', {
                  ref: entry.ref,
                })
              }
            >
              {'Buy'} {formatMoney(entry.cost)}⪽
            </Button>
          </Stack.Item>
        </Stack>
      </Table.Cell>
    </Table.Row>
  );
};
