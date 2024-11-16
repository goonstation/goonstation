/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

import { Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { GasMixerData } from './types';

export const Outputs = () => {
  const { data } = useBackend<GasMixerData>();
  const { mixer_information } = data;

  return (
    <Section title="Outputs">
      {JSON.stringify(mixer_information.out.gasses)}
      {mixer_information.out.kpa &&
        mixer_information.out.temp &&
        `Pressure: ${mixer_information.out.kpa} / Temperature: ${mixer_information.out.temp} °C`}
    </Section>
  );
};
