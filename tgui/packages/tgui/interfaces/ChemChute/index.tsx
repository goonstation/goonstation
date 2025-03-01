/**
 * @file
 * @copyright 2023
 * @author Original LeahTheTech (https://github.com/TobleroneSwordfish)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { ProductList } from '../common/ProductList';
import type { ChemChuteData } from './type';

export const ChemChute = () => {
  const { data } = useBackend<ChemChuteData>();
  const { productList } = data;
  return (
    <Window title="Dispensary Interlink Stock View" width={355} height={500}>
      <Window.Content>
        <Section fill fitted scrollable>
          <ProductList showCount showOutput={false}>
            {productList.map((product) => (
              <ProductList.Item
                key={product.name}
                image={product.img}
                count={product.amount}
              >
                {product.name}
              </ProductList.Item>
            ))}
          </ProductList>
        </Section>
      </Window.Content>
    </Window>
  );
};
