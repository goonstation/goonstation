import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Box, Divider, NumberInput, Section, Stack, Tooltip, Table } from '../components';
import { ButtonCheckbox } from '../components/Button';
import { Window } from '../layouts';

export const Rockbox = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    amount,
    forSale,
    name,
    price,
    stats,
  } = data;
  const [takeAmount, setTakeAmount] = useLocalState(context, 'takeAmount', 1);
  const [sellAllPrice, setSellAllPrice] = useLocalState(context, 'sellAllPrice', 0);
  return (
    <Window
      title="Rockbox"
      width={375}
      height={400}
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section fill>
              <Stack>
                <Stack.Item grow>
                  {"Amount to eject: "}
                  <NumberInput
                    value={takeAmount}
                    width={4}
                    minValue={1}
                    onDrag={(e, value) => setTakeAmount(value)}
                    onChange={(e, value) => setTakeAmount(value)}
                  />
                </Stack.Item>
                <Stack.Item mr={3}>
                  <NumberInput
                    value={sellAllPrice}
                    width={4}
                    minValue={0}
                    format={value => "$" + value}
                    onChange={(e, value) => setSellAllPrice(value)}
                  />
                  <Button
                    color="average"
                    icon="magic"
                    onClick={() => act('sell-all-ore-at-price', { newPrice: sellAllPrice })}>
                    Sell All
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Section fill scrollable>
              {data.ores.length
                ? (
                  <Box>
                    {data.ores.map((currentOre) => (
                      <Fragment key={currentOre.name}>
                        <Tooltip
                          position="bottom"
                          content={currentOre.stats}
                        >
                          <Table>
                            <Table.Row>
                              <Table.Cell>
                                <Box>{`${currentOre.name}: ${currentOre.amount}`}</Box>
                              </Table.Cell>
                              <Table.Cell textAlign="right">
                                <Box>
                                  {'Price: '}
                                  <NumberInput
                                    value={currentOre.price}
                                    width={4}
                                    minValue={0}
                                    format={value => "$" + value}
                                    onChange={(e, value) => act('set-ore-price', {
                                      newPrice: value,
                                      ore: currentOre.name,
                                    })}
                                  />
                                  <ButtonCheckbox
                                    content="For Sale"
                                    color={currentOre.forSale ? 'green' : 'red'}
                                    checked={currentOre.forSale}
                                    onClick={() => act('toggle-ore-sell-status', { ore: currentOre.name })}
                                  />
                                  <Button
                                    color={currentOre.amount < takeAmount ? 'orange' : 'default'}
                                    disabled={currentOre.amount === 0}
                                    onClick={() => act('dispense-ore', {
                                      ore: currentOre.name,
                                      take: takeAmount,
                                    })}
                                  >
                                    Eject
                                  </Button>
                                </Box>
                              </Table.Cell>
                            </Table.Row>
                          </Table>
                        </Tooltip>
                        <Divider />
                      </Fragment>
                    ))}
                  </Box>
                )
                : <Box>No ores stored</Box>}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
