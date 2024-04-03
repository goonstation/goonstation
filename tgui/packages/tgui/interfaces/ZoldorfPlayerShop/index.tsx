/**
 * @file
 * @copyright 2024
 * @author Glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { InfernoNode } from 'inferno';
import { useBackend } from '../../backend';
import { Box, Button, Flex, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import type { ZoldorfPlayerShopData, ZoldorfProductData } from './type';

export const ZoldorfPlayerShop = (_, context) => {
  const { act, data } = useBackend<ZoldorfPlayerShopData>(context);
  const { soul_products, credit_products, credits } = data;
  return (
    <Window width="500" height="600">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Section fill scrollable>
              <Stack vertical>
                {soul_products.map((product) => {
                  return (
                    <ZoldorfProductList {...product} key={product.name}>
                      <Button
                        color="red"
                        content={`${product.soul_percentage}%`}
                        disabled={product.soul_percentage > data.user_soul}
                        onClick={() => act('soul_purchase', { 'item': product.name })}
                        style={{
                          'width': '50px',
                        }}
                      />
                    </ZoldorfProductList>
                  );
                })}
                {credit_products.map((product) => {
                  return (
                    <ZoldorfProductList {...product} key={product.name}>
                      <Button
                        color="green"
                        content={`${product.price}⪽`}
                        disabled={product.price > credits}
                        onClick={() => act('credit_purchase', { 'item': product.name })}
                        width="50px"
                      />
                    </ZoldorfProductList>
                  );
                })}
              </Stack>
            </Section>
          </Stack.Item>
          {credits !== 0 && (
            <Stack.Item bold>
              <Box inline>{`Cash: ${credits}⪽`}</Box>
              <Button ml="5px" icon="eject" content={'eject'} onClick={() => act('returncash')} />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

interface ZoldorfProductListProps extends ZoldorfProductData {
  children: InfernoNode;
}

const ZoldorfProductList = (props: ZoldorfProductListProps) => {
  const { name, img, stock, infinite, children } = props;
  return (
    <Flex
      style={{
        'align-items': 'center',
        'border-bottom': '1px #555 solid',
      }}>
      <Flex.Item>
        {img && (
          <Box
            style={{
              'position': 'relative', // condense total line-height
              'height': '24px', // 24px height - 32px sprite = -8px margin
              'top': '-4px', // -8px margin / 2 = -4px top offset
            }}>
            <img src={`data:image/png;base64,${img}`} />
          </Box>
        )}
      </Flex.Item>
      <Flex.Item grow>
        <Box>
          <Box inline italic>
            {!infinite && `${stock} x`}&nbsp;
          </Box>
          <Box inline>{name}</Box>
        </Box>
      </Flex.Item>
      <Flex.Item bold style={{ 'text-align': 'center' }}>
        {children}
      </Flex.Item>
    </Flex>
  );
};
