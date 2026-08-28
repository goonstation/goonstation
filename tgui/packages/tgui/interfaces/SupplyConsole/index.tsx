/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */

import {
  BlockQuote,
  Button,
  LabeledList,
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
import {
  SupplyConsoleData,
  SupplyConsoleTabKeys,
  SupplyConsoleTabKeysToTitles,
} from './type';

export const SupplyConsole = () => {
  return (
    <ConsoleMenu
      see_rockbox
      see_account={false}
      can_accept_orders
      shown_tabs={[
        SupplyConsoleTabKeys.Requests,
        SupplyConsoleTabKeys.Supplies,
        SupplyConsoleTabKeys.History,
        SupplyConsoleTabKeys.Market,
        SupplyConsoleTabKeys.Traders,
        SupplyConsoleTabKeys.Requisitions,
      ]}
    />
  );
};

interface SupplyConsoleProps {
  see_rockbox: boolean;
  see_account: boolean;
  shown_tabs: number[];
  can_accept_orders: boolean;
}
export const ConsoleMenu = (props: SupplyConsoleProps) => {
  const { data, act } = useBackend<SupplyConsoleData>();
  const [viewing_tab, setTab] = useSharedState(
    'viewtab',
    SupplyConsoleTabKeys.Requests,
  );
  const { see_rockbox, see_account, shown_tabs, can_accept_orders } = props;
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
              {see_account && (
                <Stack.Item>
                  <Section title="User Account">
                    <UserAccount />
                  </Section>
                </Stack.Item>
              )}
              <Stack.Item grow>
                <Section title="Menu Selection" fill>
                  <Tabs vertical fill>
                    {shown_tabs.map((tab) => (
                      <SupplyConsoleTab
                        key={tab}
                        tabID={tab}
                        tabName={
                          tab === SupplyConsoleTabKeys.Requests
                            ? `Requests (${data.requests.length})`
                            : SupplyConsoleTabKeysToTitles[tab]
                        }
                      />
                    ))}
                  </Tabs>
                </Section>
              </Stack.Item>
              {see_rockbox && (
                <Stack.Item>
                  <Section title="Rockbox Controls">
                    <RockboxControls />
                  </Section>
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            {viewing_tab === SupplyConsoleTabKeys.Requests && (
              <SupplyConsoleRequestsTab can_accept_orders={can_accept_orders} />
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

const UserAccount = () => {
  const { data, act } = useBackend<SupplyConsoleData>();
  return (
    <Stack>
      {!!data.account_data.scanned_name && (
        <Stack vertical>
          <LabeledList>
            <LabeledList.Item label="Name">
              {data.account_data.scanned_name}
            </LabeledList.Item>
            <LabeledList.Item label="Rank">
              {data.account_data.scanned_job}
            </LabeledList.Item>
            <LabeledList.Item label="Credits">
              {data.account_data.scanned_credits}
            </LabeledList.Item>
          </LabeledList>
          <Button width="100%" onClick={() => act('contribute')} icon="coins">
            Donate to Supply Budget
          </Button>
          <Button width="100%" onClick={() => act('logout')} icon="minus">
            Log Out
          </Button>
        </Stack>
      )}

      {!data.account_data.scanned_name && (
        <Button width="100%" onClick={() => act('scan_id')} icon="id-card">
          Swipe ID
        </Button>
      )}
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
