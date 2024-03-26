/**
 * @file
 * @copyright 2024
 * @author Glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { useBackend } from "../../backend";
import { Box, Button, Flex, Section, Stack, Table } from "../../components";
import { Window } from "../../layouts";
import { ZoldorfPlayerShopData, ZoldorfProductListProps } from "./type";

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
            <Section fill scrollable height="100%">
              <Stack vertical>
                {
                  soul_products.map(product => {
                    return (
                      <ZoldorfProductList {...product} key={product.name}>
                        <Button
                          color="red"
                          disabled={product.soul_percentage > data.user_soul}
                          onClick={() => act('soul_purchase', { "item": product.name })}
                          style={{ "width": "50px", "text-align": "center", "padding": "0px" }}
                          content={("" + product.soul_percentage + "%")}
                        />
                      </ZoldorfProductList>
                    );
                  })
                }
              </Stack>
              <Stack vertical>
                {
                  credit_products.map(product => {
                    return (
                      <ZoldorfProductList {...product} key={product.name}>
                        <Button
                          color="green"
                          disabled={product.price > credits}
                          content={("" + product.price + "⪽")}
                          onClick={() => act('credit_purchase', { "item": product.name })}
                          style={{ "width": "50px", "text-align": "center", "padding": "0px" }}
                        />
                      </ZoldorfProductList>
                    );
                  })
                }
              </Stack>
            </Section>
          </Stack.Item>
          { credits !== 0 && (
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
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ZoldorfProductList = (props: ZoldorfProductListProps) => {
  const {
    name,
    img,
    stock,
    infinite,
    children,
  } = props;
  return (
    <Flex justify="space-between" align="stretch" style={{ "border-bottom": "1px #555 solid" }}>
      <Flex.Item direction="row">
        {img && (
          <Box style={{ "overflow": "show", "height": "24px" }}>
            <img
              src={`data:image/png;base64,${img}`}
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
            {!infinite && `${stock} x`}&nbsp;
          </Box>
          <Box inline>{name}</Box>
        </Box>
      </Flex.Item>
      <Flex.Item bold direction="row" style={{ "margin-left": "5px",
        "display": "flex",
        "justify-content": "center",
        "flex-direction": "column",
      }}>
        {children}
      </Flex.Item>
    </Flex>
  );
};
