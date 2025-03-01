/**
 * @file
 * @copyright 2024
 * @author Glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { Box, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { ProductList, type ProductListItemProps } from '../common/ProductList';
import { asCreditsString } from '../common/stringUtils';
import { VendorCashTable } from '../common/VendorCashTable';
import type { ZoldorfPlayerShopData } from './type';
import { isSoulProductData } from './type';

export const ZoldorfPlayerShop = () => {
  const { act, data } = useBackend<ZoldorfPlayerShopData>();
  const { products, credits, user_soul } = data;
  return (
    <Window width={500} height={600}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section fill fitted scrollable>
              <ProductList>
                {products.map((product) => {
                  const { img, infinite, name, stock } = product;
                  const buyProps: Pick<
                    ProductListItemProps,
                    'canBuy' | 'costSlot' | 'onBuy'
                  > = isSoulProductData(product)
                    ? {
                        canBuy:
                          !product.soul_percentage ||
                          user_soul >= product.soul_percentage,
                        costSlot: (
                          <Box color="red" bold>
                            {`${product.soul_percentage}%`}
                          </Box>
                        ),
                        onBuy: () => act('soul_purchase', { item: name }),
                      }
                    : {
                        canBuy: !product.price || credits >= product.price,
                        costSlot: asCreditsString(product.price),
                        onBuy: () => act('credit_purchase', { item: name }),
                      };
                  return (
                    <ProductList.Item key={name} {...buyProps} image={img}>
                      {!infinite && (
                        <Box inline italic>
                          {`${stock} x`}&nbsp;
                        </Box>
                      )}
                      {name}
                    </ProductList.Item>
                  );
                })}
              </ProductList>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <VendorCashTable
              rejectCard
              cash={credits}
              onCashClick={() => act('returncash')}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
