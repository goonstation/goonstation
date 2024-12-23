/**
 * @file
 * @copyright 2024
 * @author EleSeu (https://github.com/EleSeu)
 * @license ISC
 */

import { Button, Flex, Icon, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ReagentGraph } from './common/ReagentInfo';

interface IceCreamMachineData {
  beaker;
  cone;
  flavors;
}

export const StandardFlavors = () => {
  const { act, data } = useBackend<IceCreamMachineData>();
  const standardFlavors = data.flavors;

  return (
    <Section title="Standard Flavors">
      {standardFlavors.map((flavor, flavorIndex) => (
        <Button
          key={flavorIndex}
          className="chem-dispenser__dispense-buttons"
          align="left"
          width="130px"
          m=".1rem"
          onClick={() => act('make_ice_cream', { flavor: flavor.name })}
        >
          <Icon
            color={
              'rgba(' +
              flavor.colorR +
              ',' +
              flavor.colorG +
              ', ' +
              flavor.colorB +
              ', 1)'
            }
            name="circle"
            pt={1}
            style={{ textShadow: '0 0 3px #000' }}
          />
          {flavor.name}
        </Button>
      ))}
    </Section>
  );
};

export const BeakerFlavor = () => {
  const { act, data } = useBackend<IceCreamMachineData>();
  const beaker = data.beaker;

  return (
    <Section title="Custom Flavor" fill>
      <ReagentGraph container={beaker} />
      <Flex wrap>
        <Flex.Item>
          <Button
            key="beaker"
            mt=".5rem"
            mr=".5rem"
            className="chem-dispenser__dispense-buttons"
            icon="check"
            color="green"
            disabled={!beaker || !beaker.totalVolume}
            tooltip={beaker && !beaker.totalVolume ? 'Beaker Is Empty' : ''}
            onClick={() => act('make_ice_cream', { flavor: 'beaker' })}
          >
            Make Custom Ice Cream
          </Button>
        </Flex.Item>
        <Flex.Item>
          <Button
            mt=".5rem"
            className="chem-dispenser__dispense-buttons"
            icon="eject"
            onClick={() =>
              !beaker ? act('insert_beaker') : act('eject_beaker')
            }
          >
            {!beaker
              ? 'Insert Beaker'
              : 'Eject ' +
                beaker.name +
                ' (' +
                beaker.totalVolume +
                '/' +
                beaker.maxVolume +
                ')'}
          </Button>
        </Flex.Item>
      </Flex>
    </Section>
  );
};

export const IceCreamMachine = () => {
  const { act, data } = useBackend<IceCreamMachineData>();
  const cone = data.cone;

  return (
    <Window title="Ice Cream-O-Mat 6300" width={440} height={275}>
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
              onClick={() => act('eject_cone')}
            >
              Eject Cone
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
