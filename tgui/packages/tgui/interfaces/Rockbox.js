
import { useBackend, useSharedState } from '../backend';
import { Button, LabeledList, Section, NumberInput, Box, Divider, Tooltip } from '../components';
import { Window } from '../layouts';

export const Rockbox = (props, context) => {
  const { act, data }=useBackend(context);
  const {
    name,
    amount,
    forSale,
    price,
    stats,
  }=data;
  const [takeAmount, setTakeAmount] = useSharedState(context, 'takeAmount', 1);
  return (

    <Window
      title="Rockbox"
      width={500}
      height={500}
      scrollable
    >
      <Window.Content>
        <Section>
          <Box>{"Take Amount: "}
            <NumberInput
              value={takeAmount}
              width={4}
              minValue={1}
              onDrag={(e, value) => setTakeAmount(value)}
            />
          </Box>
        </Section>
        <Section>
          {data.ores.length ? (
            <LabeledList>
              {data.ores.map((currentOre) => (
                <>
                  <Tooltip
                    position={"bottom"}
                    content={currentOre.name === "Gem" ? "Properties vary" : currentOre.stats}
                  >
                    <Box>
                      <LabeledList.Item
                        label={currentOre.name}
                        key={currentOre.name}
                        buttons={(
                          <>
                            <Box>{"Price: "}
                              <NumberInput
                                value={currentOre.price}
                                width={4}
                                minValue={0}
                                format={value => "$" + value}
                                onChange={(e, value) => act('set-ore-price', { newPrice: value, ore: currentOre.name })}
                              />
                            </Box>
                            <Button
                              content={currentOre.forSale ? "Ore for sale" : "Ore not for sale"}
                              color={currentOre.forSale ? 'green' : 'red'}
                              onClick={() => act('set-ore-sell-status', { ore: currentOre.name })}
                            />
                            <Button
                              content={"Take ore"}
                              disabled={takeAmount > currentOre.amount}
                              onClick={() => act('dispense-ore', { ore: currentOre.name, take: takeAmount })}
                            />
                          </>
                        )}>{currentOre.amount}
                      </LabeledList.Item>
                    </Box>
                  </Tooltip>
                  <Divider />
                </>
              ))}
            </LabeledList>
          )
            : (
              <Box>{"No ores stored"}
              </Box>
            )}
        </Section>
      </Window.Content>
    </Window>
  );
};
