/**
 * @file
 * @copyright 2024
 * @author EleSeu (https://github.com/EleSeu)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Button, Flex, Icon, Section, Stack } from '../components';
import { Window } from '../layouts';
import { ReagentGraph } from './common/ReagentInfo';

export const StandardFlavors = (props, context) => {
  const { act, data } = useBackend(context);
  const standardFlavors = data.flavors;

  return (
    <Section title="Standard Flavors" >
      {standardFlavors.map((flavor, flavorIndex) => (
        <Button
          key={flavorIndex}
          className="chem-dispenser__dispense-buttons"
          align="left"
          width="130px"
          m=".1rem"
          onClick={() => act("make_ice_cream", { flavor: flavor.name })}
        >
          <Icon
            color={"rgba(" + flavor.colorR + "," + flavor.colorG + ", " + flavor.colorB + ", 1)"}
            name="circle"
            pt={1}
            style={{ "text-shadow": "0 0 3px #000" }}
          />
          {flavor.name}
        </Button>
      ))}
    </Section>
  );
};

export const BeakerFlavor = (props, context) => {
  const { act, data } = useBackend(context);
  const beaker = data.beaker;

  return (
    <Section title="Custom Flavor" fill>
      <ReagentGraph container={beaker} />
      <Flex wrap >
        <Flex.Item>
          <Button key="beaker"
            mt=".5rem"
            mr=".5rem"
            className="chem-dispenser__dispense-buttons"
            icon="check" color="green"
            disabled={!beaker || !beaker.totalVolume}
            tooltip={beaker && !beaker.totalVolume ? "Beaker Is Empty" : ""}
            onClick={() => act("make_ice_cream", { flavor: "beaker" })}>
            Make Custom Ice Cream
          </Button>
        </Flex.Item>
        <Flex.Item>
          <Button
            mt=".5rem"
            className="chem-dispenser__dispense-buttons"
            icon="eject"
            onClick={() => !beaker ? act("insert_beaker") : act("eject_beaker")} >
            {!beaker ? "Insert Beaker" : "Eject " + beaker.name + " (" + beaker.totalVolume + "/" + beaker.maxVolume + ")"}
          </Button>
        </Flex.Item>
      </Flex>
    </Section>
  );
};

export const IceCreamMachine = (props, context) => {
  const { data } = useBackend(context);
  const cone = data.cone;

  return (
    <Window
      title="Ice Cream-O-Mat 6300"
      width={440}
      height={275}>
      <Window.Content>
        <Stack m="0.25rem" vertical fill>
          <Stack.Item>
            <StandardFlavors />
          </Stack.Item>
          <Stack.Item>
            <BeakerFlavor />
          </Stack.Item>
          <Stack.Item m=".25rem">
            <Button
              mt="0.5rem"
              icon="eject"
              className="chem-dispenser__buttons"
              disabled={!cone}
              onClick={() => act("eject_cone")} >
              Eject Cone
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
