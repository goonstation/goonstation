/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */

import { useState } from 'react';
import {
  Box,
  Button,
  Image,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { resource } from '../../goonstation/cdn';
import { Window } from '../../layouts';
import { CommodityData, TraderData } from './type';

export const Trader = () => {
  const { data, act } = useBackend<TraderData>();
  const [viewing_sell_tab, setSellTab] = useState(true);
  return (
    <Window width={600} height={700}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <TraderInfo />
          </Stack.Item>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={!!viewing_sell_tab}
                onClick={() => {
                  setSellTab(true);
                  act('viewsold');
                }}
              >
                Selling Items
              </Tabs.Tab>
              <Tabs.Tab
                selected={!viewing_sell_tab}
                onClick={() => {
                  setSellTab(false);
                  act('viewbought');
                }}
              >
                Buying Items
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable noTopPadding>
              {!!viewing_sell_tab && (
                <Table>
                  {data.goods_sell.map((commodity) => (
                    <CommodityEntry
                      key={commodity.ref}
                      commodity={commodity}
                      view_type={'selling'}
                    />
                  ))}
                </Table>
              )}
              {!viewing_sell_tab && (
                <Table>
                  {data.goods_buy.map((commodity) => (
                    <CommodityEntry
                      key={commodity.ref}
                      commodity={commodity}
                      view_type={'buying'}
                    />
                  ))}
                </Table>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const TraderInfo = () => {
  const { data, act } = useBackend<TraderData>();
  return (
    <Stack fill>
      <Stack.Item>
        {data.image && <Image src={resource('images/traders/' + data.image)} />}
      </Stack.Item>
      <Stack.Item grow>
        <Stack vertical fill>
          <Section title={data.name} fill>
            <Section>
              <Stack.Item>
                <b>{data.currency_name} in account:</b>{' '}
                {data.available_currency | 0}
              </Stack.Item>
              {!!data.accepts_card && (
                <Stack.Item>
                  <Button
                    icon="id-card"
                    onClick={() => {
                      act('card');
                    }}
                  >
                    {data.scanned_card || 'No ID scanned'}
                  </Button>
                </Stack.Item>
              )}
            </Section>
            <Section>
              <Stack.Item>
                <b>Items in cart:</b> {data.items_in_cart}
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="cart-shopping"
                  color="green"
                  onClick={() => {
                    act('pickupcart');
                  }}
                >
                  Pickup Cart
                </Button>
              </Stack.Item>
            </Section>
          </Section>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

type CommodityProps = {
  commodity: CommodityData;
  view_type: string;
};

const CommodityEntry = (props: CommodityProps) => {
  const { commodity, view_type } = props;
  const { data, act } = useBackend<TraderData>();
  return (
    <Table.Row className="candystripe">
      <Table.Cell py="5px">
        <Box mb="5px" bold>
          {commodity.name}
        </Box>
        <Box>{commodity.description}</Box>
      </Table.Cell>
      <Table.Cell py="5px" align="right">
        <Stack vertical>
          <Stack.Item>
            <Button
              icon={view_type === 'selling' ? 'cart-shopping' : 'coins'}
              onClick={() =>
                act(view_type === 'selling' ? 'purchase' : 'sell', {
                  ref: commodity.ref,
                })
              }
            >
              {view_type === 'selling' ? 'Buy' : 'Sell'} {commodity.price}{' '}
              {data.currency_name}
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="comments"
              onClick={() =>
                act('haggle', {
                  ref: commodity.ref,
                })
              }
            >
              Haggle
            </Button>
          </Stack.Item>
          <Stack.Item>
            {view_type === 'selling' && commodity.amount_left && (
              <Box> {commodity.amount_left} Left!</Box>
            )}
          </Stack.Item>
        </Stack>
      </Table.Cell>
    </Table.Row>
  );
};
