/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { SteppedSlider } from './SteppedSlider';
import type { TeleConsoleData } from './types';
import { formatDecimal } from './util';

export const CoordinatesSection = () => {
  const { act, data } = useBackend<TeleConsoleData>();
  const { xTarget, yTarget, zTarget } = data;
  return (
    <Section title="Target">
      <LabeledList>
        <LabeledList.Item label="X">
          <SteppedSlider
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
          <SteppedSlider
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
          <SteppedSlider
            maxValue={14}
            minValue={0}
            onChange={(value) => act('setZ', { value })}
            stepPixelSize={16}
            value={zTarget}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
