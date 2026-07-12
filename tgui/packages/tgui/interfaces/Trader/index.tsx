/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */

import { useState } from 'react';
import {
  BlockQuote,
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
import { capitalize } from './../common/stringUtils';
import { CommodityData, TraderData } from './type';

export const Trader = () => {
  const { data, act } = useBackend<TraderData>();
  const [viewing_tab, setTab] = useState('sell');
  return (
    <Window theme={data.theme} width={600} height={700}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <TraderInfo />
          </Stack.Item>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={viewing_tab === 'sell'}
                onClick={() => {
                  setTab('sell');
                  act('viewsold');
                }}
              >
                Selling Items
              </Tabs.Tab>
              <Tabs.Tab
                selected={viewing_tab === 'buy'}
                onClick={() => {
                  setTab('buy');
                  act('viewbought');
                }}
              >
                Buying Items
              </Tabs.Tab>
              <Tabs.Tab
                selected={viewing_tab === 'cart'}
                onClick={() => {
                  setTab('cart');
                }}
              >
                View Cart
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable noTopPadding>
              {viewing_tab === 'sell' && (
                <Table>
                  {data.goods_sell.map((commodity) => (
                    <CommodityEntry
                      key={commodity.ref}
                      commodity={commodity}
                      view_type={'selling'}
                      currency_name={data.currency_name}
                      trader_ref={null}
                    />
                  ))}
                </Table>
              )}
              {viewing_tab === 'buy' && (
                <Table>
                  {data.goods_buy.map((commodity) => (
                    <CommodityEntry
                      key={commodity.ref}
                      commodity={commodity}
                      view_type={'buying'}
                      currency_name={data.currency_name}
                      trader_ref={null}
                    />
                  ))}
                </Table>
              )}
              {viewing_tab === 'cart' && (
                <Table>
                  {data.items_in_cart.map((item, index) => (
                    <Table.Row className="candystripe" key={index}>
                      <Table.Cell width="32px">
                        <Image
                          height="32px"
                          width="32px"
                          src={`data:image/png;base64,${item.iconBase64}`}
                        />
                      </Table.Cell>
                      <Table.Cell verticalAlign="middle">
                        <Box>{capitalize(item.name)}</Box>
                      </Table.Cell>
                    </Table.Row>
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
          <Section
            title={data.name}
            buttons={
              <Button
                onClick={() => {
                  act('whoareyou');
                }}
              >
                Who are you?
              </Button>
            }
            fill
          >
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
                <b>Items in cart:</b> {data.items_in_cart.length}
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

// trader_ref is used by the QM console which has multiple traders in one UI
type CommodityProps = {
  commodity: CommodityData;
  view_type: string;
  currency_name: string;
  trader_ref: string | null;
};

// Also used by QM console traders
export const CommodityEntry = (props: CommodityProps) => {
  const { commodity, view_type, currency_name, trader_ref } = props;
  const { act } = useBackend();
  const formattedCurrency =
    currency_name === '⪽' ? currency_name : ' ' + currency_name;
  return (
    <Table.Row className="candystripe">
      <Table.Cell py="5px">
        <Box mb="5px">
          <b>{commodity.name}</b>{' '}
          {commodity.amount_left !== -1 &&
            '— ' + commodity.amount_left + ' Left!'}
        </Box>
        <BlockQuote>{commodity.description}</BlockQuote>
      </Table.Cell>
      <Table.Cell py="5px" align="right">
        <Stack vertical>
          <Stack.Item>
            <Button
              icon={view_type === 'selling' ? 'cart-shopping' : 'coins'}
              disabled={commodity.amount_left === 0}
              onClick={() =>
                act(
                  view_type === 'selling' ? 'trader_purchase' : 'trader_sell',
                  {
                    commodity_ref: commodity.ref,
                    trader_ref: trader_ref,
                  },
                )
              }
            >
              {view_type === 'selling' ? 'Buy' : 'Sell'} {commodity.price}
              {formattedCurrency}
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="comments"
              onClick={() =>
                act('trader_haggle', {
                  commodity_ref: commodity.ref,
                  trader_ref: trader_ref,
                })
              }
            >
              Haggle
            </Button>
          </Stack.Item>
        </Stack>
      </Table.Cell>
    </Table.Row>
  );
};
