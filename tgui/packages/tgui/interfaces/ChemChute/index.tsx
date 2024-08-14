/**
 * @file
 * @copyright 2023
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @license MIT
 */

import { Box, Flex, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { ChemChuteData } from './type';

export const ChemChute = () => {
  const { data } = useBackend<ChemChuteData>();
  const { productList } = data;
  return (
    <Window title="Medical supply chute console" width={355} height={500}>
      <Window.Content>
        <Section
          fill
          scrollable
          title="Dispensary interlink stock view"
          height="100%"
        >
          {productList.map((product) => {
            return (
              <Flex
                key={product.name}
                justify="space-between"
                align="stretch"
                style={{ borderBottom: '1px #555 solid' }}
              >
                <Flex.Item direction="row">
                  {product.img && (
                    <Box style={{ overflow: 'show', height: '24px' }}>
                      <img
                        src={`data:image/png;base64,${product.img}`}
                        style={{
                          transform: 'translate(0, -4px)',
                        }}
                      />
                    </Box>
                  )}
                </Flex.Item>
                <Flex.Item
                  direction="row"
                  grow
                  style={{
                    display: 'flex',
                    justifyContent: 'center',
                    flexDirection: 'column',
                  }}
                >
                  <Box>
                    <Box inline italic>
                      {`${product.amount} x`}&nbsp;
                    </Box>
                    <Box inline>{product.name}</Box>
                  </Box>
                </Flex.Item>
                <Flex.Item
                  bold
                  direction="row"
                  style={{
                    marginLeft: '5px',
                    display: 'flex',
                    justifyContent: 'center',
                    flexDirection: 'column',
                  }}
                />
              </Flex>
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
