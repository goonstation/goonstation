import {
  Box,
  Button,
  Collapsible,
  Divider,
  Flex,
  Image,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { VendorCashTable } from './common/VendorCashTable';

interface VendorsData {
  bankMoney;
  busy;
  busyphrase;
  cardname;
  cash;
  currentlyVending;
  lightColors;
  loading;
  name;
  owner;
  playerBuilt;
  productList;
  requiresMoney;
  unlocked;
  windowName;
  wiresList;
  wiresOpen;
}

export const Vendors = () => {
  const { act, data } = useBackend<VendorsData>();
  const wiresList = data.wiresList || [];
  const productList = data.productList || [];
  const indicators = data.lightColors || [];

  const {
    windowName,
    wiresOpen,
    cash,
    bankMoney,
    requiresMoney,
    cardname,
    playerBuilt,
    name,
    owner,
    unlocked,
    loading,
    busy,
    busyphrase,
    currentlyVending,
  } = data;

  const canVend = (a) =>
    (a.cost <= cash || a.cost <= bankMoney || !requiresMoney) && a.amount > 0;
  const getCost = (a) => (a.cost && requiresMoney ? `${a.cost}⪽` : 'Vend');

  return (
    <Window title={windowName} width={500} height={600}>
      <Window.Content>
        <Stack vertical fill minHeight="1%" maxHeight="100%">
          {wiresOpen && (
            <Stack.Item>
              <Collapsible mb="1%" title="Wire Panel">
                {wiresOpen &&
                  wiresList.map((wire) => {
                    return (
                      <Flex key={wire.name} textColor={wire.color}>
                        <Flex.Item grow bold>
                          {wire.name}
                        </Flex.Item>
                        <Flex.Item mr="5%">
                          <Button
                            ml="10%"
                            my="1%"
                            onClick={() =>
                              act('pulsewire', {
                                wire: wire.name,
                              })
                            }
                          >
                            Pulse
                          </Button>
                        </Flex.Item>
                        <Flex.Item>
                          <Button
                            m="1%"
                            onClick={() =>
                              act(wire.uncut ? 'cutwire' : 'mendwire', {
                                wire: wire.name,
                              })
                            }
                          >
                            {wire.uncut ? 'Cut' : 'Mend'}
                          </Button>
                        </Flex.Item>
                      </Flex>
                    );
                  })}

                <Divider />
                {playerBuilt && (
                  <>
                    <Button onClick={() => act('togglelock')}>
                      {`Owner: ${owner} (${unlocked ? 'Unlocked' : 'Locked'})`}
                    </Button>
                    <Button
                      disabled={!unlocked}
                      color={loading ? 'green' : 'red'}
                      onClick={() => act('togglechute')}
                    >
                      Loading Chute
                    </Button>
                    <Button.Input
                      defaultValue={name}
                      onCommit={(e, value) => act('rename', { name: value })}
                    >
                      {name}
                    </Button.Input>
                  </>
                )}
                <Flex justify="space-between" align="stretch">
                  <Flex.Item direction="row">
                    <LabeledList>
                      <LabeledList.Item label="AI Control">
                        {indicators.ai_control ? 'Enabled' : 'Disabled'}
                      </LabeledList.Item>
                      <LabeledList.Item label="Electrification">
                        {indicators.electrified ? 'Yes' : 'No'}
                      </LabeledList.Item>
                    </LabeledList>
                  </Flex.Item>
                  <Flex.Item direction="row">
                    <LabeledList.Item label="Inventory">
                      {indicators.extendedinventory ? 'Expanded' : 'Standard'}
                    </LabeledList.Item>
                    <LabeledList.Item label="Safety Light">
                      {indicators.shootinventory ? 'On' : 'Off'}
                    </LabeledList.Item>
                  </Flex.Item>
                </Flex>
              </Collapsible>
            </Stack.Item>
          )}
          <Stack.Item grow minHeight="1%" maxHeight="100%">
            <Section fill scrollable height="100%">
              {!busy &&
                productList.map((product) => {
                  return (
                    <Flex
                      key={product.name}
                      justify="space-between"
                      align="stretch"
                      style={{ borderBottom: '1px #555 solid' }}
                    >
                      <Flex.Item direction="row">
                        {product.img && (
                          <Box style={{ overflow: 'show', height: '24px' }}>
                            <img
                              src={`data:image/png;base64,${product.img}`}
                              style={{
                                transform: 'translate(0, -4px)',
                              }}
                            />
                          </Box>
                        )}
                      </Flex.Item>
                      <Flex.Item
                        direction="row"
                        grow
                        style={{
                          display: 'flex',
                          justifyContent: 'center',
                          flexDirection: 'column',
                        }}
                      >
                        <Box>
                          <Box inline italic>
                            {!product.infinite && `${product.amount} x`}&nbsp;
                          </Box>
                          <Box inline>
                            {product.name}
                            {playerBuilt && wiresOpen && (
                              <Button
                                inline
                                color="green"
                                icon="images"
                                style={{ marginLeft: '5px' }}
                                onClick={() =>
                                  act('setIcon', { target: product.ref })
                                }
                              />
                            )}
                          </Box>
                        </Box>
                      </Flex.Item>
                      <Flex.Item
                        bold
                        direction="row"
                        style={{
                          marginLeft: '5px',
                          display: 'flex',
                          justifyContent: 'center',
                          flexDirection: 'column',
                        }}
                      >
                        {playerBuilt && unlocked ? (
                          <Button.Input
                            color={canVend(product) ? 'green' : 'grey'}
                            style={{ width: '50px', textAlign: 'center' }}
                            onCommit={(e, value) =>
                              act('setPrice', {
                                target: product.ref,
                                cost: value,
                              })
                            }
                          >
                            {getCost(product)}
                          </Button.Input>
                        ) : (
                          <Button
                            color={canVend(product) ? 'green' : 'grey'}
                            disabled={canVend(product) ? false : true}
                            style={{
                              width: '50px',
                              textAlign: 'center',
                              padding: '0px',
                            }}
                            onClick={() =>
                              act('vend', {
                                target: product.ref,
                                cost: product.cost,
                                amount: product.amount,
                              })
                            }
                          >
                            {getCost(product)}
                          </Button>
                        )}
                      </Flex.Item>
                    </Flex>
                  );
                })}
              {!!busy && (
                <Stack vertical>
                  <Stack.Item align="center">
                    <Image
                      height="128px"
                      width="128px"
                      src={`data:image/png;base64,${productList.find((product) => product.name === currentlyVending).img}`}
                    />
                  </Stack.Item>
                  <Stack.Item align="center">{busyphrase}</Stack.Item>
                </Stack>
              )}
            </Section>
          </Stack.Item>
          {requiresMoney > 0 && (
            <Stack.Item>
              <VendorCashTable
                cardname={cardname}
                onCardClick={() => act('logout')}
                bankMoney={bankMoney}
                cash={cash}
                onCashClick={() => act('returncash')}
              />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
