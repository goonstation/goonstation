import { useBackend, useLocalState } from '../backend';
import { Box, Button, Divider, Flex, Section, Stack } from '../components';
import { Window } from '../layouts';

import { capitalize, pluralize } from './common/stringUtils';

const GlassRecyclerProductEntry = (props) => {
  const {
    product: {
      name,
      cost,
      img,
    },
    disabled,
    onClick,
  } = props;

  return (
    <>
      <Flex direction="row" align="center">
        <Flex.Item>
          <img
            src={`data:image/png;base64,${img}`}
            style={{
              'vertical-align': 'middle',
              'horizontal-align': 'middle',
            }}
          />
        </Flex.Item>
        <Flex.Item grow={1}>
          <Box bold>
            {capitalize(name)}
          </Box>
          <Box>
            {`Cost: ${cost} ${pluralize('Unit', cost)}`}
          </Box>
        </Flex.Item>
        <Flex.Item>
          <Button onClick={onClick} disabled={disabled}>
            Create
          </Button>
        </Flex.Item>
      </Flex>
      <Divider />
    </>
  );
};

export const GlassRecycler = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    glassAmt,
    products,
  } = data;

  const [filterAvailable, setFilterAvailable] = useLocalState(context, 'filter-available', false);

  return (
    <Window
      title="Glass Recycler"
      width={300}
      height={400}
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Flex direction="row" align="center">
                <Flex.Item grow={1}>
                  <Box>
                    {`Glass: ${glassAmt} ${pluralize('Unit', glassAmt)}`}
                  </Box>
                </Flex.Item>
                <Flex.Item>
                  <Button.Checkbox checked={filterAvailable} onClick={() => setFilterAvailable(!filterAvailable)}>
                    Filter Available
                  </Button.Checkbox>
                </Flex.Item>
              </Flex>
            </Section>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Section
              fill
              scrollable
              title="Products"
            >
              {products
                .filter(({ cost }) => !filterAvailable || (glassAmt >= cost))
                .map(product => {
                  const {
                    cost,
                    type,
                  } = product;
                  return (
                    <GlassRecyclerProductEntry
                      key={type}
                      product={product}
                      disabled={glassAmt < cost}
                      onClick={() => act('create', { type })}
                    />
                  );
                })}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
