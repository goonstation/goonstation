/**
 * @file
 * @copyright 2024
 * @author Glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { Section, Stack } from 'tgui-core/components';

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
              <ProductList showCount showImage showOutput>
                {products.map((product) => {
                  const { img, infinite, name, stock } = product;
                  const outputSlot: ProductListItemProps['outputSlot'] =
                    isSoulProductData(product) ? (
                      <ProductList.OutputButton
                        color="red"
                        disabled={
                          product.soul_percentage !== 0 &&
                          user_soul < product.soul_percentage
                        }
                        icon="hand-holding-heart"
                        onClick={() => act('soul_purchase', { item: name })}
                      >
                        {`${product.soul_percentage}%`}
                      </ProductList.OutputButton>
                    ) : (
                      <ProductList.OutputButton
                        disabled={product.price > 0 && credits < product.price}
                        onClick={() => act('credit_purchase', { item: name })}
                      >
                        {asCreditsString(product.price)}
                      </ProductList.OutputButton>
                    );
                  return (
                    <ProductList.Item
                      key={name}
                      image={img}
                      outputSlot={outputSlot}
                      count={infinite ? undefined : stock}
                    >
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
