/**
 * @file
 * @copyright 2024
 * @author Glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { ReactNode } from 'react';
import { Box, Button, Image, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import type { ZoldorfCommonProductData, ZoldorfPlayerShopData } from './type';
import { isSoulProductData } from './type';

export const ZoldorfPlayerShop = () => {
  const { act, data } = useBackend<ZoldorfPlayerShopData>();
  const { products, credits } = data;
  return (
    <Window width={500} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Section fill scrollable>
              <Stack vertical>
                {products.map((product) => {
                  return (
                    <ZoldorfProductListItem {...product} key={product.name}>
                      {isSoulProductData(product) ? (
                        <Button
                          color="red"
                          disabled={product.soul_percentage > data.user_soul}
                          onClick={() =>
                            act('soul_purchase', { item: product.name })
                          }
                          align="center"
                          width="50px"
                        >
                          {`${product.soul_percentage}%`}
                        </Button>
                      ) : (
                        <Button
                          color="green"
                          disabled={product.price > credits}
                          onClick={() =>
                            act('credit_purchase', { item: product.name })
                          }
                          align="center"
                          width="50px"
                        >
                          {`${product.price}⪽`}
                        </Button>
                      )}
                    </ZoldorfProductListItem>
                  );
                })}
              </Stack>
            </Section>
          </Stack.Item>
          {credits !== 0 && (
            <Stack.Item bold>
              <Box inline>{`Cash: ${credits}⪽`}</Box>
              <Button ml={1} icon="eject" onClick={() => act('returncash')}>
                Eject
              </Button>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

interface ZoldorfProductListItemProps extends ZoldorfCommonProductData {
  children: ReactNode;
}

const ZoldorfProductListItem = (props: ZoldorfProductListItemProps) => {
  const { name, img, stock, infinite, children } = props;
  return (
    <Stack.Item height="20px">
      <Stack
        align="center"
        style={{
          borderBottom: '1px solid #555', // match vending machine border
          paddingBottom: '2px', // align border between buttons
        }}
      >
        <Stack.Item>
          <Box
            position="relative" // don't increase line-height, but keep image size
            height="20px" // 20 px height - 32 px sprite = -12 px of offset
            top="-6px" // -12px / 2 = -6px top offset to keep them centered
          >
            {img && <Image src={`data:image/png;base64,${img}`} />}
          </Box>
        </Stack.Item>
        <Stack.Item grow>
          <>
            {!infinite && (
              <Box inline italic>
                {`${stock} x`}&nbsp;
              </Box>
            )}
            <Box inline>{name}</Box>
          </>
        </Stack.Item>
        <Stack.Item bold>{children}</Stack.Item>
      </Stack>
    </Stack.Item>
  );
};
