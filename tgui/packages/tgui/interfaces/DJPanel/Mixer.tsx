/**
 * @file
 * @copyright 2020, 2026
 * @author Original ZeWaka (https://github.com/ZeWaka)
 * @author Changes Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import {
  Button,
  LabeledList,
  NumberInput,
  Slider,
  Stack,
} from 'tgui-core/components';
import { numberOfDecimalDigits, round } from 'tgui-core/math';

import { useBackend } from '../../backend';
import type { DJPanelData } from './types';

const VOLUME_MIN = 0;
const VOLUME_MAX = 200;
const VOLUME_STEP = 1;
const DEFAULT_VOLUME = 50;
const FREQUENCY_MIN = -4;
const FREQUENCY_MAX = 4;
const FREQUENCY_STEP = 0.05;
const DEFAULT_FREQUENCY = 1;

export const Mixer = () => {
  const { act, data } = useBackend<DJPanelData>();
  const { volume, frequency, soundsEnabled } = data;
  return (
    <LabeledList>
      <MixerControlItem
        label="Volume"
        value={volume}
        minValue={VOLUME_MIN}
        maxValue={VOLUME_MAX}
        step={VOLUME_STEP}
        unit="%"
        disabled={!soundsEnabled}
        resetTooltip={`Reset volume to ${DEFAULT_VOLUME}%`}
        onChange={(value) => act('set-volume', { volume: value })}
        onReset={() => act('reset-volume')}
      />
      <MixerControlItem
        label="Pitch"
        value={frequency}
        defaultValue={DEFAULT_FREQUENCY}
        minValue={FREQUENCY_MIN}
        maxValue={FREQUENCY_MAX}
        step={FREQUENCY_STEP}
        unit="x"
        disabled={!soundsEnabled}
        resetTooltip={`Reset pitch to ${DEFAULT_FREQUENCY}x`}
        onChange={(value) => act('set-freq', { frequency: value })}
        onReset={() => act('reset-freq')}
      />
    </LabeledList>
  );
};

interface MixerControlProps {
  label: string;
  value: number;
  defaultValue?: number;
  minValue: number;
  maxValue: number;
  step: number;
  unit: string;
  disabled: boolean;
  resetTooltip: string;
  onChange: (value: number) => void;
  onReset: () => void;
}

const MixerControlItem = (props: MixerControlProps) => {
  const {
    label,
    defaultValue,
    unit,
    resetTooltip,
    onChange,
    onReset,
    ...inputProps
  } = props;
  const formatValue = (value: number) =>
    `${round(value, numberOfDecimalDigits(inputProps.step))}`;
  return (
    <LabeledList.Item label={label} verticalAlign="middle">
      <Stack align="center">
        <Stack.Item grow>
          <Slider
            {...inputProps}
            fillValue={defaultValue}
            format={formatValue}
            unit={unit}
            onChange={(_event, value) => onChange(value)}
          />
        </Stack.Item>
        <Stack.Item>
          <NumberInput
            {...inputProps}
            format={formatValue}
            unit={unit}
            width={5.5}
            onChange={onChange}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="undo"
            tooltip={resetTooltip}
            disabled={inputProps.disabled}
            onClick={onReset}
          />
        </Stack.Item>
      </Stack>
    </LabeledList.Item>
  );
};
