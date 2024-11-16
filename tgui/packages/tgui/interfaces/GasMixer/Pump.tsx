/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

import { Button, Flex, Section, Slider } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { GasMixerData } from './types';

export const Pump = () => {
  const { data, act } = useBackend<GasMixerData>();
  const { mixer_information } = data;

  return (
    <Section title="Pump" height="100%" mx={1}>
      <Flex>
        <Flex.Item>
          <Section title="Gas Input Ratio">
            <Slider
              minValue={0}
              maxValue={100}
              value={mixer_information.i1trans}
              onChange={(_e, value) => act('ratio', { ratio: value })}
            />
          </Section>
        </Flex.Item>
        <Flex.Item>
          <Section title="Output Target Pressure">
            <Slider
              minValue={0}
              maxValue={100}
              value={mixer_information.target_pressure}
              onChange={(_e, value) =>
                act('pressure_set', { target_pressure: value })
              }
            />
          </Section>
          <Section title="Pump Status">
            <Button
              icon="power-off"
              color={
                mixer_information.pump_status === 'Online' ? 'average' : null
              }
              onClick={() => act('toggle_pump')}
            >
              {mixer_information.pump_status}
            </Button>
          </Section>
        </Flex.Item>
      </Flex>
    </Section>
  );
};
