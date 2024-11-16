/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

import { Flex, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { GasMixerData } from './types';

export const Inputs = () => {
  const { data } = useBackend<GasMixerData>();
  const { mixer_information } = data;

  return (
    <Section title="Inputs">
      <Flex>
        <Flex.Item>
          <Section title="Input 1">
            {JSON.stringify(mixer_information.in1.gasses)}
            {mixer_information.in1.kpa &&
              mixer_information.in1.temp &&
              `Pressure: ${mixer_information.in1.kpa} kPa / Temperature: ${mixer_information.in1.temp} °C`}
          </Section>
        </Flex.Item>
        <Flex.Item>
          <Section title="Input 2">
            {JSON.stringify(mixer_information.in2.gasses)}
            {mixer_information.in2.kpa &&
              mixer_information.in2.temp &&
              `Pressure: ${mixer_information.in2.kpa} kPa / Temperature: ${mixer_information.in2.temp} °C`}
          </Section>
        </Flex.Item>
      </Flex>
    </Section>
  );
};
