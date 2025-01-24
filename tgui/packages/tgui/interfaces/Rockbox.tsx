import { Fragment, useState } from 'react';
import {
  Box,
  Button,
  Divider,
  NumberInput,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface RockboxData {
  autosell;
  default_price;
  ores;
}

export const Rockbox = () => {
  const { act, data } = useBackend<RockboxData>();
  const { autosell, default_price, ores } = data;
  const [takeAmount, setTakeAmount] = useState(1);
  return (
    <Window title="Rockbox" width={375} height={400}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section fill>
              <Box>
                {'Amount to eject: '}
                <NumberInput
                  value={takeAmount}
                  minValue={1}
                  maxValue={Infinity}
                  step={1}
                  onDrag={(value) => setTakeAmount(value)}
                  onChange={(value) => setTakeAmount(value)}
                />
              </Box>
              <Divider />
              <Tooltip
                content="Default price for new ore entries."
                position="bottom"
              >
                <Box as="span">
                  {/* necessary for tooltip to work */}
                  {'Default Price: '}
                  <NumberInput
                    value={default_price}
                    minValue={0}
                    maxValue={Infinity}
                    step={1}
                    format={(value) => value + '⪽'}
                    onChange={(value) =>
                      act('set-default-price', { newPrice: value })
                    }
                  />
                </Box>
              </Tooltip>
              <Button.Checkbox
                checked={autosell}
                tooltip="Mark new ore entries for sale automatically."
                onClick={() => act('toggle-auto-sell')}
              >
                Auto-Sell
              </Button.Checkbox>
            </Section>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Section fill scrollable>
              {ores.length ? (
                <Box>
                  {data.ores.map((currentOre) => (
                    <Fragment key={currentOre.name}>
                      <Tooltip position="bottom" content={currentOre.stats}>
                        <Table>
                          <Table.Row>
                            <Table.Cell style={{ verticalAlign: 'top' }}>
                              <Box>{`${currentOre.name}: ${currentOre.amount}`}</Box>
                            </Table.Cell>
                            <Table.Cell textAlign="right">
                              <Stack vertical textAlign="left" inline>
                                <Stack.Item>
                                  {'Price: '}
                                  <NumberInput
                                    value={currentOre.price}
                                    minValue={0}
                                    maxValue={Infinity}
                                    step={1}
                                    format={(value) => value + '⪽'}
                                    onChange={(value) =>
                                      act('set-ore-price', {
                                        newPrice: value,
                                        ore: currentOre.name,
                                      })
                                    }
                                  />
                                  <Button.Checkbox
                                    content="For Sale"
                                    color={currentOre.forSale ? 'green' : 'red'}
                                    checked={currentOre.forSale}
                                    onClick={() =>
                                      act('toggle-ore-sell-status', {
                                        ore: currentOre.name,
                                      })
                                    }
                                  />
                                  <Button
                                    color={
                                      currentOre.amount < takeAmount
                                        ? 'orange'
                                        : 'default'
                                    }
                                    disabled={currentOre.amount === 0}
                                    onClick={() =>
                                      act('dispense-ore', {
                                        ore: currentOre.name,
                                        take: takeAmount,
                                      })
                                    }
                                  >
                                    Eject
                                  </Button>
                                </Stack.Item>
                                <Stack.Item>
                                  {!!currentOre.amountSold && (
                                    <Box>{`Amount sold: ${currentOre.amountSold}`}</Box>
                                  )}
                                </Stack.Item>
                              </Stack>
                            </Table.Cell>
                          </Table.Row>
                        </Table>
                      </Tooltip>
                      <Divider />
                    </Fragment>
                  ))}
                </Box>
              ) : (
                <Box>No ores stored</Box>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
