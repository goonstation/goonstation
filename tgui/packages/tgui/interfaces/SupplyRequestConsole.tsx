/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */

import {
  Button,
  LabeledList,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { MarketInformation, SupplyConsoleTab } from './SupplyConsole/index';
import { SupplyConsoleData, SupplyConsoleTabKeys } from './SupplyConsole/type';
import { SupplyConsoleRequestsTab } from './SupplyConsole/RequestsTab';
import { SupplyConsoleSuppliesTab } from './SupplyConsole/SuppliesTab';

interface SupplyRequestConsoleData extends SupplyConsoleData {
  scanned_name: string;
  scanned_job: string;
  scanned_credits: number;
}

export const SupplyRequestConsole = () => {
  const { data, act } = useBackend<SupplyRequestConsoleData>();
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
              <Stack.Item>
                <Section title="User Account">
                  {!!data.scanned_name && (
                    <Stack vertical>
                      <LabeledList>
                        <LabeledList.Item label="Name">
                          {data.scanned_name}
                        </LabeledList.Item>
                        <LabeledList.Item label="Rank">
                          {data.scanned_job}
                        </LabeledList.Item>
                        <LabeledList.Item label="Credits">
                          {data.scanned_credits}
                        </LabeledList.Item>
                      </LabeledList>
                      <Button
                        width="100%"
                        onClick={() => act('contribute')}
                        icon="coins"
                      >
                        Donate to Supply Budget
                      </Button>
                    </Stack>
                  )}
                  {!data.scanned_name && (
                    <Button
                      width="100%"
                      onClick={() => act('scan_id')}
                      icon="id-card"
                    >
                      Swipe ID
                    </Button>
                  )}
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
                  </Tabs>
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
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
