/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Button, Icon, Slider, Stack } from 'tgui-core/components';
import { clamp } from 'tgui-core/math';

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

export const SteppedSlider = (props: SteppedSliderProps) => {
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
    <Stack width="100%">
      <Stack.Item>
        <Button
          icon="backward-fast"
          onClick={() => onChange(minValue)}
          tooltip={`Minimum (${minValue})`}
          tooltipPosition="bottom"
        />
        {!!skipAmount && (
          <Button
            icon="backward"
            onClick={() => handleAdjust(-skipAmount)}
            tooltip={`Skip Down (${-skipAmount})`}
            tooltipPosition="bottom"
          />
        )}
        <Button
          icon="backward-step"
          onClick={() => handleAdjust(-resolvedStepAmount)}
          tooltip={`Step Down (${-resolvedStepAmount})`}
          tooltipPosition="bottom"
        />
        {!!nudgeAmount && (
          <Button
            onClick={() => handleAdjust(-nudgeAmount)}
            tooltip={`Nudge Down (${-nudgeAmount})`}
            tooltipPosition="bottom"
          >
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
        {!!nudgeAmount && (
          <Button
            icon="play"
            onClick={() => handleAdjust(nudgeAmount)}
            tooltip={`Nudge Up (+${nudgeAmount})`}
            tooltipPosition="bottom"
          />
        )}
        <Button
          icon="forward-step"
          onClick={() => handleAdjust(resolvedStepAmount)}
          tooltip={`Step Up (+${resolvedStepAmount})`}
          tooltipPosition="bottom"
        />
        {!!skipAmount && (
          <Button
            icon="forward"
            onClick={() => handleAdjust(skipAmount)}
            tooltip={`Skip Up (+${skipAmount})`}
            tooltipPosition="bottom"
          />
        )}
        <Button
          icon="fast-forward"
          onClick={() => onChange(maxValue)}
          tooltip={`Maximum (${maxValue})`}
          tooltipPosition="bottom"
        />
      </Stack.Item>
    </Stack>
  );
};
