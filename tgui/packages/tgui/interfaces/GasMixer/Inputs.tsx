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

export const Inputs = () => {
  const { data } = useBackend<GasMixerData>();
  const { mixer_information } = data;

  return (
    <>
      <Section title="Input 1">
        <MixInfo mix={mixer_information.in1} />
      </Section>
      <Section title="Input 2">
        <MixInfo mix={mixer_information.in2} />
      </Section>
    </>
  );
};
