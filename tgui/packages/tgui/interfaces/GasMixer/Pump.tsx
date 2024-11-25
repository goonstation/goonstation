/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

import {
  Button,
  LabeledList,
  NumberInput,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { GasMixerData } from './types';

export const Pump = () => {
  return (
    <Section title="Pump">
      <LabeledList>
        <LabeledList.Item label="Gas Input Ratio">
          <GasInputRatio />
        </LabeledList.Item>
        <LabeledList.Item label="Target Pressure" verticalAlign="middle">
          <OutputTargetPressure />
        </LabeledList.Item>
        <LabeledList.Item label="Pump Status">
          <PumpStatus />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const GasInputRatio = () => {
  const { data, act } = useBackend<GasMixerData>();
  const { mixer_information } = data;

  return (
    <Slider
      minValue={0}
      maxValue={100}
      stepPixelSize={4}
      value={mixer_information.in1_ratio}
      onChange={(_e, value) => act('ratio', { ratio: value })}
      format={(value) => `${value}% Input 1 — ${100 - value}% Input 2`}
    />
  );
};

const OutputTargetPressure = () => {
  const { data, act } = useBackend<GasMixerData>();
  const { mixer_information, MAX_PRESSURE } = data;

  return (
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
          onChange={(value) => act('pressure_set', { target_pressure: value })}
          unit="kPa"
          fluid
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          onClick={() => act('pressure_set', { target_pressure: MAX_PRESSURE })}
        >
          Max
        </Button>
      </Stack.Item>
    </Stack>
  );
};

const PumpStatus = () => {
  const { data, act } = useBackend<GasMixerData>();
  const { mixer_information } = data;

  return (
    <Button
      icon="power-off"
      color={mixer_information.pump_status === 'Online' ? 'average' : null}
      onClick={() => act('toggle_pump')}
      fluid
      textAlign="center"
      py={1}
    >
      {mixer_information.pump_status}
    </Button>
  );
};
