/**
 * @file
 * @copyright 2024
 * @author Glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { InfernoNode } from 'inferno';
import { useBackend } from '../../backend';
import { Box, Button, Image, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { isSoulProductData } from './type';
import type { ZoldorfCommonProductData, ZoldorfPlayerShopData } from './type';

export const ZoldorfPlayerShop = (_, context) => {
  const { act, data } = useBackend<ZoldorfPlayerShopData>(context);
  const { products, credits } = data;
  return (
    <Window width="500" height="600">
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
                          content={`${product.soul_percentage}%`}
                          disabled={product.soul_percentage > data.user_soul}
                          onClick={() => act('soul_purchase', { 'item': product.name })}
                          align="center"
                          width="50px"
                        />
                      ) : (
                        <Button
                          color="green"
                          content={`${product.price}⪽`}
                          disabled={product.price > credits}
                          onClick={() => act('credit_purchase', { 'item': product.name })}
                          align="center"
                          width="50px"
                        />
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
              <Button ml={1} icon="eject" content="Eject" onClick={() => act('returncash')} />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

interface ZoldorfProductListItemProps extends ZoldorfCommonProductData {
  children: InfernoNode;
}

const ZoldorfProductListItem = (props: ZoldorfProductListItemProps) => {
  const { name, img, stock, infinite, children } = props;
  return (
    <Stack.Item height="20px">
      <Stack
        align="center"
        style={{
          "border-bottom": "1px solid #555", // match vending machine border
          "padding-bottom": "2px", // align border between buttons
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
            {!infinite && <Box inline italic>{`${stock} x`}&nbsp;</Box>}
            <Box inline>{name}</Box>
          </>
        </Stack.Item>
        <Stack.Item bold>
          {children}
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};
