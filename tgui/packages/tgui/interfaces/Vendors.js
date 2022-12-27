import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Box, Button, Section, Table, Image } from 'tgui/components';
import { Collapsible, Flex, Stack } from '../components';
import { WirePanelCoverStatus } from './common/WirePanel/type';
import { WirePanelStack } from './WirePanelWindow';

export const Vendors = (props, context) => {
  const { act, data } = useBackend(context);
  const productList = data.productList || [];

  const {
    windowName,
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
    wirePanelDynamic,
  } = data;

  const canVend = (a) => (
    ((((a.cost <= cash) || (a.cost <= bankMoney)) || !requiresMoney) && (a.amount > 0))
  );
  const getCost = (a) => (
    (((a.cost) && requiresMoney) ? `${a.cost}⪽` : "Vend")
  );

  return (
    <Window
      title={windowName}
      width="500"
      height="600"
      fontFamily="Consolas"
      font-size="10pt">
      <Window.Content>
        <WirePanelStack vertical fill minHeight="1%" maxHeight="100%">
          {!!playerBuilt && (
            <Stack.Item>
              <Collapsible
                mb="1%"
                title="Vendor Controls"
                disabled={!!wirePanelDynamic.user_is_remote && !wirePanelDynamic.can_access_remotely}
                open={!!wirePanelDynamic.user_is_remote && !wirePanelDynamic.can_access_remotely}>
                <>
                  <Button content={`Owner: ${owner} (${unlocked ? "Unlocked" : "Locked"})`} onClick={() => act("togglelock")} />
                  <Button content="Loading Chute" disabled={!unlocked} color={loading ? "green" : "red"} onClick={() => act("togglechute")} />
                  <Button.Input content={name} defaultValue={name} onCommit={(e, value) => act("rename", { name: value })} />
                </>
              </Collapsible>
            </Stack.Item>
          )}
          <Stack.Item grow minHeight="1%" maxHeight="100%">
            <Section fill scrollable height="100%">
              {!busy && (
                productList.map(product => {
                  return (
                    <Flex key={product.name} justify="space-between" align="stretch" style={{ "border-bottom": "1px #555 solid" }}>
                      <Flex.Item direction="row">
                        {product.img && (
                          <Box style={{ "overflow": "show", "height": "24px" }}>
                            <img
                              src={`data:image/png;base64,${product.img}`}
                              style={{
                                'transform': 'translate(0, -4px)',
                              }}
                            />
                          </Box>)}
                      </Flex.Item>
                      <Flex.Item direction="row"
                        grow style={{
                          "display": "flex",
                          "justify-content": "center",
                          "flex-direction": "column",
                        }}>
                        <Box>
                          <Box inline italic>
                            {!product.infinite && `${product.amount} x`}&nbsp;
                          </Box>
                          <Box inline>
                            {product.name}
                            {(playerBuilt && wirePanelDynamic.cover_status === WirePanelCoverStatus.WPANEL_COVER_OPEN)
                            && (
                              <Button inline
                                color="green"
                                icon="images"
                                style={{ "margin-left": "5px" }}
                                onClick={() => act('setIcon', { target: product.path })}
                              />
                            )}
                          </Box>
                        </Box>
                      </Flex.Item>
                      <Flex.Item bold direction="row" style={{ "margin-left": "5px",
                        "display": "flex",
                        "justify-content": "center",
                        "flex-direction": "column",
                      }}>
                        {(playerBuilt && unlocked) ? <Button.Input
                          color={canVend(product) ? "green" : "grey"}
                          content={getCost(product)}
                          style={{ "width": "50px", "text-align": "center" }}
                          onCommit={(e, value) => act('setPrice', { target: product.path, cost: value })}
                        /> : <Button
                          color={canVend(product) ? "green" : "grey"}
                          content={getCost(product)}
                          disabled={canVend(product) ? false : true}
                          style={{ "width": "50px", "text-align": "center", "padding": "0px" }}
                          onClick={() => act('vend', {
                            target: product.path, cost: product.cost, amount: product.amount })}
                        />}
                      </Flex.Item>
                    </Flex>
                  );
                })
              )}
              {!!busy && (
                <Stack vertical>
                  <Stack.Item align="center">
                    <Image
                      height="128px"
                      width="128px"
                      pixelated
                      src={
                        `data:image/png;base64,${productList.find(product => product.name === currentlyVending).img}`
                      } />
                  </Stack.Item>
                  <Stack.Item align="center">{busyphrase}</Stack.Item>
                </Stack>
              )}
            </Section>
          </Stack.Item>
          {requiresMoney > 0 && (
            <Stack.Item>
              <Table font-size="9pt" direction="row">
                <Table.Row>
                  <Table.Cell bold>
                    {cardname && (
                      <Button icon="id-card"
                        mr="100%"
                        content={cardname ? cardname : ""}
                        onClick={() => act('logout')}
                      />
                    )}
                    {(cardname && bankMoney >= 0) && ("Money on account: " + bankMoney + "⪽")}
                  </Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold direction="row">
                    {(cash > 0) && ("Cash: " + cash + "⪽")}
                    {(cash > 0 && cash) && (
                      <Button icon="eject"
                        ml="1%"
                        content={"eject"}
                        onClick={() => act('returncash')} />
                    )}
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Stack.Item>
          )}
        </WirePanelStack>

      </Window.Content>
    </Window>
  );

};
