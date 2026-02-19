import { useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  Divider,
  Flex,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const SBPurchaseEntry = (props) => {
  const {
    product: { pname, cost, img },
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
              verticalAlign: 'middle',
            }}
          />
        </Flex.Item>
        <Flex.Item grow={1}>
          <Box bold>{pname}</Box>
          <Box>
            {`Cost: ${cost}`} <i className="fas fa-coins" />
          </Box>
        </Flex.Item>
        <Flex.Item>
          <Button onClick={onClick} disabled={disabled}>
            Buy
          </Button>
        </Flex.Item>
      </Flex>
      <Divider />
    </>
  );
};

interface SpendSpacebuxData {
  purchasables;
  held;
  balance;
  truebalance;
}

export const SpendSpacebux = (_props, context) => {
  const { act, data } = useBackend<SpendSpacebuxData>();
  const { purchasables, held, balance, truebalance } = data;

  const [filterAvailable, setFilterAvailable] = useState(false);

  return (
    <Window title="Spend Spacebux" width={300} height={600}>
      <Window.Content scrollable>
        <Section>
          <BlockQuote>
            Purchase an item for the upcoming round. Earn more cash by
            completing rounds. A purchased item will persist until you die or
            fail to escape the station. If you have a Held Item, buying a new
            one will replace it.
          </BlockQuote>
          <Stack vertical fill>
            {held ? (
              <Stack.Item>
                <Box>Held Item: {held}</Box>
              </Stack.Item>
            ) : (
              ''
            )}
            <Stack.Item>
              <Section>
                <Flex direction="row" align="center">
                  <Flex.Item grow={1}>
                    <Box>
                      Balance: {balance} <i className="fas fa-coins" />
                    </Box>
                  </Flex.Item>
                  <Flex.Item>
                    <Button.Checkbox
                      checked={filterAvailable}
                      onClick={() => setFilterAvailable(!filterAvailable)}
                    >
                      Filter Affordable
                    </Button.Checkbox>
                  </Flex.Item>
                </Flex>
              </Section>
            </Stack.Item>
            <Stack.Item>
              {purchasables
                .filter(({ cost }) => !(filterAvailable && truebalance < cost))
                .map((purchase) => {
                  const { pname, cost } = purchase;
                  return (
                    <SBPurchaseEntry
                      key={pname}
                      product={purchase}
                      disabled={truebalance < cost}
                      onClick={() => act('purchase', { pname })}
                    />
                  );
                })}
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
