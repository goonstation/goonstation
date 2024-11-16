/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

import { Button, Section, Slider, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { GasMixerData } from './types';

export const Pump = () => {
  const { data, act } = useBackend<GasMixerData>();
  const { mixer_information, MAX_PRESSURE } = data;

  return (
    <Section title="Pump">
      <Section title="Gas Input Ratio">
        <Stack>
          <Stack.Item>
            <Button onClick={() => act('ratio', { ratio: 0 })}>
              0% Input 1
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Slider
              minValue={0}
              maxValue={100}
              stepPixelSize={4}
              value={mixer_information.i1trans}
              onChange={(_e, value) => act('ratio', { ratio: value })}
            />
          </Stack.Item>
          <Stack.Item>
            <Button onClick={() => act('ratio', { ratio: 100 })}>
              0% Input 2
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
      <Section title="Output Target Pressure">
        <Stack>
          <Stack.Item>
            <Button onClick={() => act('pressure_set', { target_pressure: 0 })}>
              0 kPa
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Slider
              minValue={0}
              maxValue={MAX_PRESSURE}
              step={5}
              value={mixer_information.target_pressure}
              onChange={(_e, value) =>
                act('pressure_set', { target_pressure: value })
              }
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              onClick={() =>
                act('pressure_set', { target_pressure: MAX_PRESSURE })
              }
            >
              {MAX_PRESSURE} kPa
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
      <Section title="Pump Status">
        <Button
          icon="power-off"
          color={mixer_information.pump_status === 'Online' ? 'average' : null}
          onClick={() => act('toggle_pump')}
        >
          {mixer_information.pump_status}
        </Button>
      </Section>
    </Section>
  );
};
