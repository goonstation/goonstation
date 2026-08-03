/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */

import {
  BlockQuote,
  NumberInput,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../../backend';
import { formatMoney } from '../../format';
import { Window } from '../../layouts';
import { SupplyConsoleHistoryTab } from './HistoryTab';
import { SupplyConsoleMarketTab } from './MarketTab';
import { SupplyConsoleRequestsTab } from './RequestsTab';
import { SupplyConsoleRequisitionsTab } from './RequisitionsTab';
import { SupplyConsoleSuppliesTab } from './SuppliesTab';
import { SupplyConsoleTradersTab } from './TradersTab';
import { SupplyConsoleData, SupplyConsoleTabKeys } from './type';

export const SupplyConsole = () => {
  const { data, act } = useBackend<SupplyConsoleData>();
  const [viewing_tab, setTab] = useSharedState(
    'viewtab',
    SupplyConsoleTabKeys.Requests,
  );
  return (
    <Window theme={'retro-dark'} width={900} height={500}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width={'200px'}>
            <Stack vertical fill>
              <Stack.Item>
                <Section title="Market Information">
                  <MarketInformation />
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Section title="Menu Selection" fill>
                  <Tabs vertical fill>
                    <SupplyConsoleTab
                      tabID={SupplyConsoleTabKeys.Requests}
                      tabName={`Requests (${data.requests.length})`}
                    />
                    <SupplyConsoleTab
                      tabID={SupplyConsoleTabKeys.Supplies}
                      tabName={'Place Order'}
                    />
                    <SupplyConsoleTab
                      tabID={SupplyConsoleTabKeys.History}
                      tabName={'Order History'}
                    />
                    <SupplyConsoleTab
                      tabID={SupplyConsoleTabKeys.Market}
                      tabName={'Shipping Market'}
                    />
                    <SupplyConsoleTab
                      tabID={SupplyConsoleTabKeys.Traders}
                      tabName={'Traders'}
                    />
                    <SupplyConsoleTab
                      tabID={SupplyConsoleTabKeys.Requisitions}
                      tabName={'Requisitions'}
                    />
                  </Tabs>
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Section title="Rockbox Controls">
                  <RockboxControls />
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            {viewing_tab === SupplyConsoleTabKeys.Requests && (
              <SupplyConsoleRequestsTab />
            )}
            {viewing_tab === SupplyConsoleTabKeys.Supplies && (
              <SupplyConsoleSuppliesTab />
            )}
            {viewing_tab === SupplyConsoleTabKeys.History && (
              <SupplyConsoleHistoryTab />
            )}
            {viewing_tab === SupplyConsoleTabKeys.Market && (
              <SupplyConsoleMarketTab />
            )}
            {viewing_tab === SupplyConsoleTabKeys.Traders && (
              <SupplyConsoleTradersTab />
            )}
            {viewing_tab === SupplyConsoleTabKeys.Requisitions && (
              <SupplyConsoleRequisitionsTab />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MarketInformation = () => {
  const { data } = useBackend<SupplyConsoleData>();
  return (
    <Stack vertical fill>
      <Stack.Item>
        Cargo Budget: <b>{formatMoney(data.shipping_budget)}⪽</b>
      </Stack.Item>
      <Stack.Item>
        Market updates in <b>{data.market_reset_timer}</b>
      </Stack.Item>
    </Stack>
  );
};

const RockboxControls = () => {
  const { data, act } = useBackend<SupplyConsoleData>();
  return (
    <Stack vertical fill>
      <Stack.Item>
        <BlockQuote>
          Additional Rockbox fees are paid into the cargo budget.
        </BlockQuote>
      </Stack.Item>
      <Stack.Item>
        <Stack>
          <Stack.Item>Percentage Fee:</Stack.Item>
          <Stack.Item grow>
            <NumberInput
              fluid
              value={data.rockbox_transaction_percent_fee}
              minValue={0}
              unit={'%'}
              onChange={(value) =>
                act('set_rockbox_percentage_fee', { value: value })
              }
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack>
          <Stack.Item>Minimum Fee:</Stack.Item>
          <Stack.Item grow>
            <NumberInput
              fluid
              value={data.rockbox_transaction_minimum_fee}
              minValue={0}
              unit={'⪽'}
              format={formatMoney}
              onChange={(value) =>
                act('set_rockbox_minimum_fee', { value: value })
              }
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const SupplyConsoleTab = (props) => {
  const { tabID, tabName } = props;
  const [viewing_tab, setTab] = useSharedState(
    'viewtab',
    SupplyConsoleTabKeys.Requests,
  );
  return (
    <Tabs.Tab selected={viewing_tab === tabID} onClick={() => setTab(tabID)}>
      {tabName}
    </Tabs.Tab>
  );
};
