/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { clamp } from 'common/math';
import { Button, Icon, Slider, Stack } from '../../components';

// slice of props that are unchanged from standard Slider component
interface SliderProps {
  format?: (value: number) => string;
  maxValue: number;
  minValue: number;
  step?: number;
  stepPixelSize?: number;
  value: number;
}

// props that are either changed or in addition to standard Slider component
interface SteppedSliderProps extends SliderProps {
  onAdjust?: (adjust: number) => void;
  onChange: (value: number) => void;
  nudgeAmount?: number;
  stepAmount?: number;
  skipAmount?: number;
}

export const CoordinateSlider = (props: SteppedSliderProps) => {
  const {
    format,
    maxValue,
    minValue,
    onAdjust,
    onChange,
    nudgeAmount,
    skipAmount,
    step,
    stepAmount,
    value,
    ...rest
  } = props;
  const resolvedStepAmount = stepAmount ?? step ?? 1;
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
        <Button icon="backward" onClick={() => handleAdjust(-resolvedStepAmount)} />
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
          maxValue={maxValue}
          minValue={minValue}
          onChange={(_e, newValue) => onChange(newValue)}
          step={step}
          value={value}
        />
      </Stack.Item>
      <Stack.Item>
        {!!nudgeAmount && <Button icon="play" onClick={() => handleAdjust(nudgeAmount)} />}
        <Button icon="forward" onClick={() => handleAdjust(resolvedStepAmount)} />
        {!!skipAmount && <Button icon="forward-step" onClick={() => handleAdjust(skipAmount)} />}
        <Button icon="fast-forward" onClick={() => onChange(maxValue)} />
      </Stack.Item>
    </Stack>
  );
};
