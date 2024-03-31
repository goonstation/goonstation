/**
 * @file
 * @copyright 2024
 * @author Glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { useBackend } from "../../backend";
import { Box, Button, Flex, Section, Stack } from "../../components";
import { Window } from "../../layouts";
import { ZoldorfPlayerShopData, ZoldorfProductListProps } from "./type";

export const ZoldorfPlayerShop = (_, context) => {
  const { act, data } = useBackend<ZoldorfPlayerShopData>(context);
  const { soul_products, credit_products, credits } = data;
  return (
    <Window width="500" height="600">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Section fill scrollable >
              <Stack vertical>
                {
                  soul_products.map(product => {
                    return (
                      <ZoldorfProductList {...product} key={product.name}>
                        <Button
                          color="red"
                          content={`${product.soul_percentage}%`}
                          disabled={product.soul_percentage > data.user_soul}
                          onClick={() => act('soul_purchase', { "item": product.name })}
                          style={{
                            "width": "50px",
                            "text-align": "center",
                          }}

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
                          content={`${product.price}⪽`}
                          disabled={product.price > credits}
                          onClick={() => act('credit_purchase', { "item": product.name })}
                          style={{
                            "width": "50px",
                            "text-align": "center",
                          }}
                        />
                      </ZoldorfProductList>
                    );
                  })
                }
              </Stack>
            </Section>
          </Stack.Item>
          { credits !== 0 && (
            <Stack.Item bold>
              <Box inline>{`Cash: ${credits}⪽`}</Box>
              <Button
                ml="5px"
                icon="eject"
                content={"eject"}
                onClick={() => act('returncash')}
              />
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
    <Flex
      style={{
        "border-bottom": "1px #555 solid",
      }}
    >
      <Flex.Item>
        {img && (
          <Box
            style={{
              "overflow": "show", // squeeze item sprites into total line height
              "position": "relative",
              "height": "24px", // 32px sprite - 24px height = 8px total margin
              "top": "-4px", // 8px margin / 2 = 4px top offset
            }}
          >
            <img src={`data:image/png;base64,${img}`} />
          </Box>)}
      </Flex.Item>
      <Flex.Item
        grow
        style={{
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
      <Flex.Item
        bold
        style={{
          "margin-left": "5px",
          "display": "flex",
          "justify-content": "center",
          "flex-direction": "column",
        }}
      >
        {children}
      </Flex.Item>
    </Flex>
  );
};
