/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */

import { Box, Icon, Section, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { SupplyConsoleData } from './type';

export const SupplyConsoleMarketTab = () => {
  const { data } = useBackend<SupplyConsoleData>();
  const marketHalfLength = Math.floor(data.market_data.length / 2);
  const marketHalfA = data.market_data.slice(0, marketHalfLength);
  const marketHalfB = data.market_data.slice(
    marketHalfLength,
    data.market_data.length,
  );
  return (
    <Section title="Shipping Market" scrollable fill>
      <Stack fill>
        <Stack.Item grow>
          <MarketTable entries={marketHalfA} />
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow>
          <MarketTable entries={marketHalfB} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const MarketTable = (props) => {
  const { entries } = props;
  return (
    <Table>
      <Table.Row>
        <Table.Cell>
          <b>Item</b>
        </Table.Cell>
        <Table.Cell />
        <Table.Cell textAlign="right">
          <b>Value</b>
        </Table.Cell>
      </Table.Row>
      {entries.map((item, index) => (
        <Table.Row className="candystripe" key={index}>
          <Table.Cell py="2px">{item.name}</Table.Cell>
          <Table.Cell align="right">
            {!!item.in_demand && (
              <Box textColor={'orange'}>
                <Icon name="fire" />
                Hot Item!
              </Box>
            )}
          </Table.Cell>
          <Table.Cell textAlign="right">{item.price}⪽</Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};
