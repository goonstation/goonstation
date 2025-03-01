import { useState } from 'react';
import { Button, Section, Stack } from 'tgui-core/components';
import { pluralize } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ProductList } from './common/ProductList';
import { capitalize } from './common/stringUtils';

interface GlassRecyclerData {
  glassAmt: number;
  products: ProductData[];
}

interface ProductData {
  name: string;
  type: string;
  cost: number;
  img: string;
}

export const GlassRecycler = () => {
  const { act, data } = useBackend<GlassRecyclerData>();
  const { glassAmt, products } = data;

  const [filterAvailable, setFilterAvailable] = useState(false);

  return (
    <Window title="Glass Recycler" width={300} height={400}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack align="center">
                <Stack.Item grow={1}>
                  {`Glass: ${glassAmt} ${pluralize('Unit', glassAmt)}`}
                </Stack.Item>
                <Stack.Item>
                  <Button.Checkbox
                    checked={filterAvailable}
                    onClick={() => setFilterAvailable(!filterAvailable)}
                  >
                    Filter Available
                  </Button.Checkbox>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Section fill fitted scrollable title="Products">
              <ProductList>
                {products
                  .filter(({ cost }) => !filterAvailable || glassAmt >= cost)
                  .map((product) => {
                    const { cost, img, name, type } = product;
                    return (
                      <ProductList.Item
                        key={type}
                        image={img}
                        outputSlot={
                          <ProductList.OutputButton
                            disabled={glassAmt < cost}
                            icon="gears"
                            onClick={() => act('create', { type })}
                          >
                            {`${cost} ${pluralize('Unit', cost)}`}
                          </ProductList.OutputButton>
                        }
                      >
                        {capitalize(name)}
                      </ProductList.Item>
                    );
                  })}
              </ProductList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
