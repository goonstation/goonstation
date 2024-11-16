/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

import {
  Button,
  Knob,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { GasMixerData } from './types';

export const Pump = () => {
  return (
    <Section title="Pump" height="100%">
      <LabeledList>
        <LabeledList.Item label="Gas Input Ratio">
          <GasInputRatio />
        </LabeledList.Item>
        <LabeledList.Item label="Output Target Pressure">
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
    <Knob
      minValue={0}
      maxValue={100}
      stepPixelSize={4}
      value={mixer_information.i1trans}
      onChange={(_e, value) => act('ratio', { ratio: value })}
      bipolar
      m={0}
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
      <Stack.Item>
        <NumberInput
          minValue={0}
          maxValue={MAX_PRESSURE}
          step={5}
          value={mixer_information.target_pressure}
          onChange={(value) => act('pressure_set', { target_pressure: value })}
          unit="kPa"
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
    >
      {mixer_information.pump_status}
    </Button>
  );
};
