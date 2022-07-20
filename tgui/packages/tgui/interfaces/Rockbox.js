import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Box, Divider, NumberInput, Section, Stack, Tooltip, Table } from '../components';
import { ButtonCheckbox } from '../components/Button';
import { Window } from '../layouts';

export const Rockbox = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    default_price,
    autosell,
  } = data;
  const [takeAmount, setTakeAmount] = useLocalState(context, 'takeAmount', 1);
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
              <Box>
                {"Amount to eject: "}
                <NumberInput
                  value={takeAmount}
                  width={4}
                  minValue={1}
                  onDrag={(e, value) => setTakeAmount(value)}
                  onChange={(e, value) => setTakeAmount(value)}
                />
              </Box>
              <Divider />
              <Tooltip content="Default price for new ore entries."
                position="bottom">
                <Box as="span"> {/* necessary for tooltip to work */}
                  {"Default Price: "}
                  <NumberInput
                    value={default_price}
                    width={4}
                    minValue={0}
                    format={value => "$" + value}
                    onChange={(e, value) => act('set-default-price', { newPrice: value })}
                  />
                </Box>
              </Tooltip>
              <Button.Checkbox
                checked={autosell}
                tooltip="Mark new ore entries for sale automatically."
                onClick={() => act('toggle-auto-sell')}>
                Auto-Sell
              </Button.Checkbox>
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
