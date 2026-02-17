/**
 * @file
 * @copyright 2026
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @license ISC
 */

import { useState } from 'react';
import {
  BlockQuote,
  Button,
  Dropdown,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface SupplyInfo {
  shipping_budget: number;
  scanned_id_name: string | null;
  account_frozen: boolean | null;
  account_credits: number | null;
  viewing_category: string;
  categories_available: string[];
  items_to_show: SupplyPack[];
  shipping_requests: ShippingRequest[];
}

interface SupplyPack {
  pack_ref: string;
  pack_name: string;
  pack_cost: number;
  pack_desc: string;
}

interface ShippingRequest {
  order_item: string;
  ordered_by: string;
  order_loc: string;
}

export const SupplyRequestConsole = () => {
  const { act, data } = useBackend<SupplyInfo>();
  const {
    shipping_budget,
    scanned_id_name,
    account_frozen,
    account_credits,
    viewing_category,
    categories_available,
    items_to_show,
    shipping_requests,
  } = data;
  const [tabIndex, setTabIndex] = useState(1);
  return (
    <Window title="Supply Request Console" width={700} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section title="Budget">
              <Stack vertical>
                <Stack.Item>
                  {`Shipping Budget: ${shipping_budget} credits`}
                </Stack.Item>
                <Stack.Item>
                  {'Scanned ID: '}
                  <Button icon="id-card" onClick={() => act('id_clicked')}>
                    {scanned_id_name ? `${scanned_id_name}` : 'No ID Scanned'}
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  {`Account: ${account_credits !== null ? (account_frozen ? 'Account frozen!' : `${account_credits} credits`) : 'No account found'} `}
                </Stack.Item>
                <Stack.Item>
                  <Button
                    disabled={
                      account_credits === null ||
                      account_credits <= 0 ||
                      account_frozen
                    }
                    onClick={() => act('contribute_to_shipping_budget')}
                  >
                    {'Add to budget'}
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={tabIndex === 1}
                onClick={() => setTabIndex(1)}
              >
                Request Items
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 2}
                onClick={() => setTabIndex(2)}
              >
                {`View Requests (${shipping_requests.length})`}
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable>
              {tabIndex === 1 && (
                <Stack vertical>
                  <Stack.Item>
                    <Dropdown
                      selected={viewing_category}
                      options={categories_available}
                      onSelected={(value: string) =>
                        act('set_viewing_category', { category: value })
                      }
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <SupplyPacksList
                      acc_frozen={account_frozen}
                      acc_credits={account_credits}
                      supply_packs={items_to_show}
                    />
                  </Stack.Item>
                </Stack>
              )}
              {tabIndex === 2 && (
                <ShippingRequestsList ship_reqs={shipping_requests} />
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

interface SupplyPacksListProps {
  acc_frozen: boolean | null;
  acc_credits: number | null;
  supply_packs: SupplyPack[];
}

const SupplyPacksList = (props: SupplyPacksListProps) => {
  const { act } = useBackend();
  const { acc_frozen, acc_credits, supply_packs } = props;
  return (
    <Stack vertical>
      {supply_packs.map((item, index) => (
        <Stack.Item key={index}>
          <Stack vertical>
            <Stack.Item>{item.pack_name}</Stack.Item>
            <Stack.Item>
              <BlockQuote>{item.pack_desc}</BlockQuote>
            </Stack.Item>
            <Stack.Item>
              <Button
                disabled={
                  acc_credits !== null &&
                  (acc_credits < item.pack_cost || acc_frozen)
                }
                icon={acc_credits === null ? 'question' : 'cart-shopping'}
                onClick={() => act('purchase', { pack_ref: item.pack_ref })}
              >
                {`${item.pack_cost} credits`}
              </Button>
            </Stack.Item>
            <Stack.Divider mb={1} />
          </Stack>
        </Stack.Item>
      ))}
    </Stack>
  );
};

interface ShippingRequestsListProps {
  ship_reqs: ShippingRequest[];
}

const ShippingRequestsList = (props: ShippingRequestsListProps) => {
  const { ship_reqs } = props;
  return (
    <Stack vertical>
      {ship_reqs.map((item, index) => (
        <Stack.Item key={index}>
          {`${index + 1}. ${item.order_item} ordered by ${item.ordered_by} from ${item.order_loc}`}
        </Stack.Item>
      ))}
    </Stack>
  );
};
