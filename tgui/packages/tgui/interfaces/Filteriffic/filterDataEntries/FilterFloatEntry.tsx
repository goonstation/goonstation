/**
 * @file
 * @copyright 2020
 * @author actioninja (https://github.com/actioninja)
 * @license MIT
 */

import { useState } from 'react';
import { Box, NumberInput } from 'tgui-core/components';
import { numberOfDecimalDigits, toFixed } from 'tgui-core/math';

import { useBackend } from '../../../backend';
import type { FilterifficData } from '../type';

interface FilterFloatEntryProps {
  value?: number | null;
  name: string;
  filterName: string;
}

export const FilterFloatEntry = (props: FilterFloatEntryProps) => {
  const { value, name, filterName } = props;
  const { act } = useBackend<FilterifficData>();
  const [step, setStep] = useState(0.01);
  return (
    <>
      <NumberInput
        value={value ?? 0}
        minValue={-500}
        maxValue={500}
        stepPixelSize={4}
        step={step}
        format={(value) => toFixed(value, numberOfDecimalDigits(step))}
        width="80px"
        onDrag={(value) =>
          act('transition_filter_value', {
            name: filterName,
            new_data: {
              [name]: value,
            },
          })
        }
      />
      <Box inline ml={2} mr={1}>
        Step:
      </Box>
      <NumberInput
        value={step}
        step={0.001}
        format={(value) => toFixed(value, 4)}
        width="70px"
        onChange={(value) => setStep(value)}
        maxValue={Infinity}
        minValue={-Infinity}
      />
    </>
  );
};
