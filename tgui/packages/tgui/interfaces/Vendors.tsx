import {
  Button,
  Collapsible,
  Divider,
  Flex,
  Image,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ProductList } from './common/ProductList';
import { VendorCashTable } from './common/VendorCashTable';

interface ProductData {
  amount: number;
  cost: number | null;
  img: string;
  infinite: BooleanLike;
  name: string;
  ref: string;
}

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
  productList: ProductData[];
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

  const canVend = (a: ProductData) =>
    (!requiresMoney || (a.cost ?? 0) <= cash || (a.cost ?? 0) <= bankMoney) &&
    (a.infinite || a.amount > 0);
  const getCostString = (a: ProductData) =>
    a.cost && requiresMoney ? `${a.cost}⪽` : undefined;

  return (
    <Window title={windowName} width={500} height={600}>
      <Window.Content>
        <Stack fill vertical>
          {wiresOpen && (
            <Stack.Item>
              <Section>
                <Collapsible title="Wire Panel">
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
                        value={name}
                        onCommit={(value) => act('rename', { name: value })}
                        buttonText={name}
                      />
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
              </Section>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Section fill fitted scrollable>
              {!busy && (
                <ProductList showCount showImage showOutput>
                  {productList.map((product) => {
                    const { amount, cost, img, infinite, name, ref } = product;
                    const costString = getCostString(product);
                    const extraCellsSlot =
                      playerBuilt && wiresOpen && unlocked ? (
                        <ProductList.Cell collapsing>
                          <Button
                            icon="images"
                            onClick={() =>
                              act('setIcon', { target: product.ref })
                            }
                            mb={0}
                            tooltip="Set as displayed product"
                          />
                          <Button.Input
                            onCommit={(value) => {
                              const parsedPrice = parseInt(value, 10);
                              if (!isNaN(parsedPrice)) {
                                act('setPrice', {
                                  target: ref,
                                  cost: Math.max(parsedPrice, 0),
                                });
                              }
                            }}
                            value={`${cost ?? 0}`}
                            buttonText="Set Price"
                          />
                        </ProductList.Cell>
                      ) : undefined;
                    return (
                      <ProductList.Item
                        key={name}
                        extraCellsSlot={extraCellsSlot}
                        outputSlot={
                          <ProductList.OutputButton
                            disabled={!canVend(product)}
                            onClick={() =>
                              act('vend', {
                                target: ref,
                                cost,
                              })
                            }
                            icon={cost ? undefined : 'eject'}
                          >
                            {costString || 'Vend'}
                          </ProductList.OutputButton>
                        }
                        image={img}
                        count={infinite ? undefined : amount}
                      >
                        {name}
                      </ProductList.Item>
                    );
                  })}
                </ProductList>
              )}
              {!!busy && (
                <Stack vertical>
                  <Stack.Item align="center">
                    <Image
                      height="128px"
                      width="128px"
                      src={`data:image/png;base64,${productList.find((product) => product.name === currentlyVending)?.img}`}
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
