import { useState } from 'react';
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
    <Window title="Rockbox" width={400} height={400}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
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
          <Stack.Item grow>
            <Section fill scrollable>
              {ores.length ? (
                <Table>
                  <Table.Row header>
                    <Table.Cell>Name</Table.Cell>
                    <Table.Cell collapsing textAlign="right">
                      Amount
                    </Table.Cell>
                    <Table.Cell collapsing textAlign="right">
                      Sold
                    </Table.Cell>
                    <Table.Cell collapsing textAlign="right">
                      Price
                    </Table.Cell>
                    <Table.Cell collapsing>For Sale</Table.Cell>
                    <Table.Cell collapsing />
                  </Table.Row>
                  {data.ores.map((currentOre) => (
                    <Table.Row key={currentOre.name} className="candystripe">
                      <Table.Cell>
                        <Tooltip position="bottom" content={currentOre.stats}>
                          <Box>{currentOre.name}</Box>
                        </Tooltip>
                      </Table.Cell>
                      <Table.Cell textAlign="right">
                        {currentOre.amount}
                      </Table.Cell>
                      <Table.Cell textAlign="right">
                        {currentOre.amountSold || 0}
                      </Table.Cell>
                      <Table.Cell textAlign="right">
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
                          fluid
                        />
                      </Table.Cell>
                      <Table.Cell>
                        <Button.Checkbox
                          color={currentOre.forSale ? 'green' : 'red'}
                          checked={currentOre.forSale}
                          onClick={() =>
                            act('toggle-ore-sell-status', {
                              ore: currentOre.name,
                            })
                          }
                          fluid
                          textAlign="center"
                        >
                          {currentOre.forSale ? 'Yes' : 'No'}
                        </Button.Checkbox>
                      </Table.Cell>
                      <Table.Cell>
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
                          icon="eject"
                          tooltip="Eject"
                        />
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
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
