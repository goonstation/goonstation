/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

import { Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { MixInfo } from './MixInfo';
import type { GasMixerData } from './types';

const INPUT_SECTIONS_HEIGHT = '100px';

export const Inputs = () => {
  const { data } = useBackend<GasMixerData>();
  const { mixer_information } = data;

  return (
    <Stack mb={1} height={INPUT_SECTIONS_HEIGHT}>
      <Stack.Item grow>
        <Section title="Input 1" fill scrollable>
          <MixInfo mix={mixer_information.in1} />
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section title="Input 2" fill scrollable>
          <MixInfo mix={mixer_information.in2} />
        </Section>
      </Stack.Item>
    </Stack>
  );
};
