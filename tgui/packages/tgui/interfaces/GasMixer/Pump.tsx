/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

import {
  Button,
  Dimmer,
  LabeledList,
  NumberInput,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { GasMixerData } from './types';

export const Pump = () => {
  const { data } = useBackend<GasMixerData>();
  const { allowed } = data;

  return (
    <Section title="Pump">
      {!allowed && <Dimmer fontSize={1.5}>Access denied</Dimmer>}
      <LabeledList>
        <GasInputRatio />
        <OutputTargetPressure />
        <PumpStatus />
      </LabeledList>
    </Section>
  );
};

const GasInputRatio = () => {
  const { data, act } = useBackend<GasMixerData>();
  const { mixer_information } = data;

  return (
    <LabeledList.Item label="Gas Input Ratio">
      <Slider
        minValue={0}
        maxValue={100}
        stepPixelSize={4}
        value={mixer_information.in1_ratio}
        onChange={(_e, value) => act('ratio', { ratio: value })}
        format={(value) => `${value}% Input 1 — ${100 - value}% Input 2`}
      />
    </LabeledList.Item>
  );
};

const OutputTargetPressure = () => {
  const { data, act } = useBackend<GasMixerData>();
  const { mixer_information, MAX_PRESSURE } = data;

  return (
    <LabeledList.Item label="Target Pressure" verticalAlign="middle">
      <Stack>
        <Stack.Item>
          <Button onClick={() => act('pressure_set', { target_pressure: 0 })}>
            Min
          </Button>
        </Stack.Item>
        <Stack.Item grow>
          <NumberInput
            minValue={0}
            maxValue={MAX_PRESSURE}
            step={5}
            value={mixer_information.target_pressure}
            onChange={(value) =>
              act('pressure_set', { target_pressure: value })
            }
            unit="kPa"
            fluid
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            onClick={() =>
              act('pressure_set', { target_pressure: MAX_PRESSURE })
            }
          >
            Max
          </Button>
        </Stack.Item>
      </Stack>
    </LabeledList.Item>
  );
};

const PumpStatus = () => {
  const { data, act } = useBackend<GasMixerData>();
  const { mixer_information } = data;

  return (
    <LabeledList.Item
      label="Pump Status"
      buttons={
        <Button icon="power-off" onClick={() => act('toggle_pump')}>
          Toggle
        </Button>
      }
    >
      {mixer_information.pump_status}
    </LabeledList.Item>
  );
};
