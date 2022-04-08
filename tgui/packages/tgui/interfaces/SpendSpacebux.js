import { useBackend, useLocalState } from '../backend';
import { BlockQuote, Button, Stack, Section } from '../components';
import { Window } from '../layouts';
import { Fragment } from 'inferno';
import { Box, Divider, Flex } from "../components";
import { capitalize, pluralize } from './common/stringUtils';

const SBPurchaseEntry = (props, context) => {
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
    <Fragment>
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
            {`Cost: $${cost}}`}
          </Box>
        </Flex.Item>
        <Flex.Item>
          <Button onClick={onClick} disabled={disabled}>
            Create
          </Button>
        </Flex.Item>
      </Flex>
      <Divider />
    </Fragment>
  );
};

export const SpendSpacebux = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    purchasables,
    held,
    balance,
  } = data;

  const [filterAvailable, setFilterAvailable] = useLocalState(context, 'filter-available', false);

  return (
    <Window
      resizable
      title="Spend Spacebux"
      width={300}
      height={600}>
      <Window.Content scrollable>
        <Section>
          <BlockQuote>Purchase an item for the upcoming round. Earn more cash by completing rounds.
            A purchased item will persist until you die or fail to escape the station.
            If you have a Held Item, buying a new one will replace it.
          </BlockQuote>
          <Stack vertical fill>
            <Stack.Item>
              <Section>
                <Flex direction="row" align="center">
                  <Flex.Item grow={1}>
                    <Box>
                      Balance: ${balance}
                    </Box>
                    {held ? <BlockQuote>Held Item: {held}</BlockQuote> : ""}
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
                title="Purchases">
                {purchasables.map(purchase => {
                  const {
                    name,
                    cost,
                    img,
                  } = purchase;
                  return (
                    <Box key>{name} {cost}</Box>
                  );
                  if (filterAvailable && (balance < cost)) {
                    return;
                  }
                  return (
                    <SBPurchaseEntry
                      key={name}
                      product={product}
                      disabled={balance < cost}
                      onClick={() => act('purchase', { name })} />
                  );
                })}
              </Section>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
