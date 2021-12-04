import { Fragment } from 'inferno';
import { useBackend, useLocalState } from "../backend";
import { Box, Button, Divider, Flex, Section, Stack } from "../components";
import { Window } from "../layouts";

// This already exists in WeaponVendor/index.tsx, but feels weird
// to make it a dependency.
const pluralize = (word, n) => (n !== 1 ? word + 's' : word);
const capitalize = (word) => word.replace(/(^\w{1})|(\s+\w{1})/g, letter => letter.toUpperCase());

const GlassRecyclerProductEntry = (props, context) => {
  const {
    product: {
      name,
      cost,
    },
    disabled,
    onClick,
  } = props;

  return (
    <Fragment>
      <Flex direction="row" align="center">
        <Flex.Item grow={1}>
          <Box bold>
            {capitalize(name)}
          </Box>
        </Flex.Item>
        <Flex.Item>
          <Button onClick={onClick} disabled={disabled}>
            Create
          </Button>
        </Flex.Item>
      </Flex>
      <Box>
        {`Cost: ${cost} ${pluralize('Unit', cost)}`}
      </Box>
      <Divider />
    </Fragment>
  );
};

export const GlassRecycler = (props, context) => {
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
      height={400}>
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
              title="Products">
              {products.map(product => {
                const {
                  type,
                  cost,
                } = product;
                if (filterAvailable && (glassAmt < cost)) {
                  return;
                }

                return (
                  <GlassRecyclerProductEntry
                    key={type}
                    product={product}
                    disabled={glassAmt < cost}
                    onClick={() => act('create', { type })} />
                );
              })}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
