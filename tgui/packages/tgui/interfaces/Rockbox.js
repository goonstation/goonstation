
import { useBackend, useSharedState } from '../backend';
import { Button, LabeledList, Section, NumberInput, Box, Collapsible } from '../components';
import { Window } from '../layouts';

export const Rockbox = (props, context) => {
  const { act, data }=useBackend(context);
  const {
    name,
    amount,
    forSale,
    price,
    radioactivity,
    radioactivityAdj,
    neutron,
    neutronAdj,
    conductivity,
    conductivityAdj,
    thermal,
    thermalAdj,
    stability,
    stabilityAdj,
    hardness,
    hardnessAdj,
    density,
    densityAdj,
    flammability,
    flammabilityAdj,
    corrosion,
    corrosionAdj,
    reflectivity,
    reflectivityAdj,
    permeability,
    permeabilityAdj,
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
                  <Collapsible
                    title={"Ore Stats"}
                    width={15}
                  >
                    <Box>{
                      currentOre.radioactivityAdj ? currentOre.radioactivityAdj+"("+currentOre.radioactivity+")" : ""
                    }
                    </Box>
                    <Box>{
                      currentOre.neutronAdj ? currentOre.neutronAdj+"("+currentOre.neutron+")" : ""
                    }
                    </Box>
                    <Box>{
                      currentOre.conductivityAdj ? currentOre.conductivityAdj+"("+currentOre.conductivity+")" : ""
                    }
                    </Box>
                    <Box>{
                      currentOre.thermalAdj ? currentOre.thermalAdj+"("+currentOre.thermal+")" : ""
                    }
                    </Box>
                    <Box>{
                      currentOre.stabilityAdj ? currentOre.stabilityAdj+"("+currentOre.stability+")" : ""
                    }
                    </Box>
                    <Box>{
                      currentOre.hardnessAdj ? currentOre.hardnessAdj+"("+currentOre.hardness+")" : ""
                    }
                    </Box>
                    <Box>{
                      currentOre.densityAdj ? currentOre.densityAdj+"("+currentOre.density+")" : ""
                    }
                    </Box>
                    <Box>{
                      currentOre.flammabilityAdj ? currentOre.flammabilityAdj+"("+currentOre.flammability+")" : ""
                    }
                    </Box>
                    <Box>{
                      currentOre.corrosionAdj ? currentOre.corrosionAdj+"("+currentOre.corrosion+")" : ""
                    }
                    </Box>
                    <Box>{
                      currentOre.reflectivityAdj ? currentOre.reflectivityAdj+"("+currentOre.reflectivity+")" : ""
                    }
                    </Box>
                    <Box>{
                      currentOre.permeabilityAdj ? currentOre.permeabilityAdj+"("+currentOre.permeability+")" : ""
                    }
                    </Box>
                  </Collapsible>
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
