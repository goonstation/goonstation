/**
 * @file
 * @copyright 2024
 * @author Glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { useBackend } from "../../backend";
import { Box, Button, Flex, Stack, Table } from "../../components";
import { Window } from "../../layouts";
import { ZoldorfPlayerShopData } from "./type";

export const ZoldorfPlayerShop = (_, context) => {
  const { act, data } = useBackend<ZoldorfPlayerShopData>(context);
  const { soul_products, credit_products, credits } = data;
  return (
    <Window
      width="500"
      height="600"
      fontFamily="Consolas"
      font-size="10pt">
      <Window.Content>
        <Stack vertical fill minHeight="1%" maxHeight="100%">
          <Stack.Item grow minHeight="1%" maxHeight="100%">
            <Stack vertical>
              {
                soul_products.map(product => {
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
                            {!product.infinite && `${product.stock} x`}&nbsp;
                          </Box>
                          <Box inline>{product.name}</Box>
                        </Box>
                      </Flex.Item>
                      <Flex.Item>
                        <Button
                          color="red"
                          onClick={() => act('soul_purchase', { "item": product.name })}
                        >{("" + product.soul_percentage + "%")}
                        </Button>
                      </Flex.Item>
                    </Flex>
                  );
                })
              }
            </Stack>
            <Stack vertical>
              {
                credit_products.map(product => {
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
                            {!product.infinite && `${product.stock} x`}&nbsp;
                          </Box>
                          <Box inline>{product.name}</Box>
                        </Box>
                      </Flex.Item>
                      <Flex.Item>
                        <Button
                          color="green"
                          disabled={product.price > credits}
                          onClick={() => act('credit_purchase', { "item": product.name })}
                        >{("" + product.price + "⪽")}
                        </Button>
                      </Flex.Item>
                    </Flex>
                  );
                })
              }
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Table>
              <Table.Row>
                <Table.Cell bold direction="row">
                  {("Cash: " + credits + "⪽")}
                  <Button
                    icon="eject"
                    ml="1%"
                    content={"eject"}
                    onClick={() => act('returncash')}
                  />
                </Table.Cell>
              </Table.Row>
            </Table>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
