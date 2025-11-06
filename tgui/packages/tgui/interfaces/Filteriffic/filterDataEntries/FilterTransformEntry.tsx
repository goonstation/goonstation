/**
 * @file
 * @copyright 2020
 * @author actioninja (https://github.com/actioninja)
 * @license MIT
 */

import { NumberInput, Stack } from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../../../backend';
import type { FilterifficData } from '../type';

interface FilterTransformEntryProps {
  value: number[] | null;
  name: string;
  filterName: string;
}

export const FilterTransformEntry = (props: FilterTransformEntryProps) => {
  const { value, name, filterName } = props;
  const { act } = useBackend<FilterifficData>();
  let transMatrix = value;
  if (transMatrix === null) {
    transMatrix = Array(1, 0, 0, 0, 1, 0);
  }
  return (
    <>
      Matrix:
      <Stack>
        {[0, 1, 2].map((col, key) => (
          <Stack.Item key={key}>
            <Stack vertical>
              {[0, 1, 2].map((row, key) => (
                <Stack.Item key={key}>
                  {col === 2 && row < 2 && 0}
                  {col === 2 && row === 2 && 1}
                  {col < 2 && (
                    <NumberInput
                      value={transMatrix[col * 3 + row]}
                      step={0.01}
                      width="50px"
                      format={(v) => toFixed(v, 2)}
                      tickWhileDragging
                      onChange={(v) => {
                        let retTrans = transMatrix;
                        retTrans[col * 3 + row] = v;
                        act('transition_filter_value', {
                          name: filterName,
                          new_data: {
                            [name]: retTrans,
                          },
                        });
                      }}
                      maxValue={Infinity}
                      minValue={-Infinity}
                    />
                  )}
                </Stack.Item>
              ))}
            </Stack>
          </Stack.Item>
        ))}
      </Stack>
    </>
  );
};
