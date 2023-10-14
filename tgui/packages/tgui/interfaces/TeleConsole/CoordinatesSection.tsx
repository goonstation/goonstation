/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { clamp } from 'common/math';
import { useBackend } from '../../backend';
import { Button, Icon, LabeledList, Section, Slider, Stack } from '../../components';
import type { TeleConsoleData } from './types';
import { formatDecimal } from './util';

interface SliderProps {
  format?: (value: number) => string;
  maxValue: number;
  minValue: number;
  step?: number;
  stepPixelSize?: number;
}

interface CoordinateSliderProps extends SliderProps {
  format?: (value: number) => string;
  onAdjust?: (adjust: number) => void;
  onChange: (value: number) => void;
  nudgeAmount?: number;
  stepAmount?: number;
  skipAmount?: number;
  value: number;
}

const CoordinateSlider = (props: CoordinateSliderProps) => {
  const {
    format,
    maxValue,
    minValue,
    onAdjust,
    onChange,
    nudgeAmount,
    skipAmount,
    stepAmount = 1,
    step,
    value,
    ...rest
  } = props;
  const handleAdjust = (adjust: number) => {
    if (onAdjust) {
      onAdjust(adjust);
      return;
    }
    onChange(clamp(value + adjust, minValue, maxValue));
  };
  return (
    <Stack inline width="100%">
      <Stack.Item>
        <Button icon="backward-fast" onClick={() => onChange(minValue)} />
        {!!skipAmount && <Button icon="backward-step" onClick={() => handleAdjust(-skipAmount)} />}
        <Button icon="backward" onClick={() => handleAdjust(-stepAmount)} />
        {!!nudgeAmount && (
          <Button onClick={() => handleAdjust(nudgeAmount)}>
            <Icon name="play" rotation={180} />
          </Button>
        )}
      </Stack.Item>
      <Stack.Item grow={1}>
        <Slider
          {...rest}
          format={format}
          value={value}
          minValue={minValue}
          maxValue={maxValue}
          step={step}
          onChange={(_e, newValue) => onChange(newValue)}
        />
      </Stack.Item>
      <Stack.Item>
        {!!nudgeAmount && <Button icon="play" onClick={() => handleAdjust(nudgeAmount)} />}
        <Button icon="forward" onClick={() => handleAdjust(stepAmount)} />
        {!!skipAmount && <Button icon="forward-step" onClick={() => handleAdjust(skipAmount)} />}
        <Button icon="fast-forward" onClick={() => onChange(maxValue)} />
      </Stack.Item>
    </Stack>
  );
};

export const CoordinatesSection = (_props, context) => {
  const { act, data } = useBackend<TeleConsoleData>(context);
  const { xTarget, yTarget, zTarget } = data;
  return (
    <Section title="Target">
      <LabeledList>
        <LabeledList.Item label="X">
          <CoordinateSlider
            format={formatDecimal}
            maxValue={500}
            minValue={0}
            nudgeAmount={0.25}
            skipAmount={10}
            stepAmount={1}
            step={0.25}
            onChange={(value) => act('setX', { value })}
            value={xTarget}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Y">
          <CoordinateSlider
            format={formatDecimal}
            maxValue={500}
            minValue={0}
            nudgeAmount={0.25}
            skipAmount={10}
            stepAmount={1}
            step={0.25}
            onChange={(value) => act('setY', { value })}
            value={yTarget}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Z">
          <CoordinateSlider
            maxValue={14}
            minValue={0}
            onChange={(value) => act('setZ', { value })}
            stepPixelSize={10}
            value={zTarget}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
