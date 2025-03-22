/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

import { Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { MixInfo } from './MixInfo';
import type { GasMixerData } from './types';

export const Output = () => {
  const { data } = useBackend<GasMixerData>();
  const { mixer_information } = data;

  return (
    <Section title="Output">
      <MixInfo mix={mixer_information.out} />
    </Section>
  );
};
