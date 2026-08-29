/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */

import {
  BlockQuote,
  Button,
  Icon,
  Image,
  Modal,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../../backend';
import { formatMoney } from '../../format';
import { resource } from '../../goonstation/cdn';
import { CommodityEntry } from '../Trader/index';
import { capitalize } from './../common/stringUtils';
import { SupplyConsoleData } from './type';

export const SupplyConsoleTradersTab = () => {
  const { data } = useBackend<SupplyConsoleData>();
  const [viewing_trader, setTrader] = useSharedState('viewtrader', -1);
  return (
    <Section
      fill
      title="Traders"
      buttons={
        viewing_trader >= 0 && (
          <Button
            icon="arrow-left"
            iconColor="white"
            textColor="white"
            color="red"
            onClick={() => {
              setTrader(-1);
            }}
          >
            Back
          </Button>
        )
      }
    >
      {data.signal_loss >= 75 && (
        <Modal
          textAlign="center"
          fontSize={2}
          p="10px"
          style={{ borderRadius: '4px' }}
          backgroundColor="red"
          textColor="white"
        >
          <Icon name="wifi" /> Severe signal interference is preventing a
          connection with trader vessels.
        </Modal>
      )}
      {viewing_trader >= 0 && <TraderView traderIndex={viewing_trader} />}
      {viewing_trader < 0 && (
        <Stack scrollable wrap="wrap">
          {data.trader_data.map((trader, index) => {
            return (
              <Stack.Item key={index}>
                <Button
                  textAlign="center"
                  color="grey"
                  textColor="white"
                  onClick={() => {
                    setTrader(index);
                  }}
                >
                  <Image src={resource('images/traders/' + trader.picture)} />
                  <br />
                  <b>{trader.name}</b>
                </Button>
              </Stack.Item>
            );
          })}
        </Stack>
      )}
    </Section>
  );
};

// Almost completely copypasted from trader UI
const TraderView = (props) => {
  const { data, act } = useBackend<SupplyConsoleData>();
  const trader = data.trader_data[props.traderIndex];
  const [traderTab, setTraderTab] = useSharedState('traderTab', 'sell');
  return (
    <Stack vertical fill>
      {trader.patience <= 0 && (
        <Modal
          textAlign="center"
          fontSize={2}
          p="10px"
          style={{ borderRadius: '4px' }}
          backgroundColor="red"
          textColor="white"
        >
          {trader.name} has left.
        </Modal>
      )}
      <Stack.Item>
        <SupplyTraderInfo trader={trader} />
      </Stack.Item>
      <Stack.Item>
        <Tabs>
          <Tabs.Tab
            selected={traderTab === 'sell'}
            onClick={() => {
              setTraderTab('sell');
            }}
          >
            Selling Items
          </Tabs.Tab>
          <Tabs.Tab
            selected={traderTab === 'buy'}
            onClick={() => {
              setTraderTab('buy');
            }}
          >
            Buying Items
          </Tabs.Tab>
          <Tabs.Tab
            selected={traderTab === 'cart'}
            onClick={() => {
              setTraderTab('cart');
            }}
          >
            View Cart
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable noTopPadding>
          {traderTab === 'sell' && (
            <Table>
              {trader.goods_sell.map((commodity) => (
                <CommodityEntry
                  key={commodity.ref}
                  commodity={commodity}
                  view_type={'selling'}
                  currency_name={'⪽'}
                  trader_ref={trader.ref}
                />
              ))}
            </Table>
          )}
          {traderTab === 'buy' && (
            <Table>
              {trader.goods_buy.map((commodity) => (
                <CommodityEntry
                  key={commodity.ref}
                  commodity={commodity}
                  view_type={'buying'}
                  currency_name={'⪽'}
                  trader_ref={trader.ref}
                />
              ))}
            </Table>
          )}
          {traderTab === 'cart' && (
            <Table>
              {trader.cart.map((item, index) => (
                <Table.Row className="candystripe" key={index}>
                  <Table.Cell>
                    <Button
                      color="bad"
                      icon="trash"
                      iconColor="white"
                      textColor="white"
                      my="3px"
                      mr="5px"
                      onClick={() =>
                        act('trader_remove_from_cart', {
                          trader_ref: trader.ref,
                          commodity_ref: item.ref,
                        })
                      }
                    />
                    {item.amount_left + 'x ' + capitalize(item.name)}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const SupplyTraderInfo = (props) => {
  const { act } = useBackend<SupplyConsoleData>();
  const { trader } = props;
  return (
    <Stack fill>
      <Stack.Item>
        <Image src={resource('images/traders/' + trader.picture)} />
      </Stack.Item>
      <Stack.Item grow>
        <Section title={trader.name} fill>
          <Stack vertical fill>
            <Stack.Item>
              <b>Items in cart:</b> {trader.cart_count} / {trader.cart_max}
            </Stack.Item>
            <Stack.Item>
              <b>Cost of cart:</b> {formatMoney(trader.cart_cost)}⪽
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="cart-shopping"
                color="green"
                iconColor="white"
                textColor="white"
                onClick={() => {
                  act('trader_buy_cart', { trader_ref: trader.ref });
                }}
              >
                Confirm Cart
              </Button>
            </Stack.Item>
            <Stack.Item>
              <BlockQuote>{trader.current_message}</BlockQuote>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
