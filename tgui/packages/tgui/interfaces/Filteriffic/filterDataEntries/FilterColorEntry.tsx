/**
 * @file
 * @copyright 2020
 * @author actioninja (https://github.com/actioninja)
 * @license MIT
 */

import {
  Box,
  Button,
  ColorBox,
  Input,
  NumberInput,
  Stack,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../../../backend';
import type { FilterifficData } from '../type';

interface FilterColorEntryProps {
  value?;
  filterName: string;
  name: string;
}

export const FilterColorEntry = (props: FilterColorEntryProps) => {
  const { value, filterName, name } = props;
  const { act } = useBackend<FilterifficData>();
  const prefixes = ['r', 'g', 'b', 'a', 'c'];
  if (Array.isArray(value)) {
    // standardise to 20 val color matrix
    let colmatrix = value;
    if (colmatrix.length < 20) {
      while (colmatrix.length < 12) {
        colmatrix.push(0);
      }
      colmatrix = Array(
        colmatrix[0],
        colmatrix[1],
        colmatrix[2],
        0,
        colmatrix[3],
        colmatrix[4],
        colmatrix[5],
        0,
        colmatrix[6],
        colmatrix[7],
        colmatrix[8],
        0,
        0,
        0,
        0,
        1,
        colmatrix[9],
        colmatrix[10],
        colmatrix[11],
        0,
      );
      while (colmatrix.length < 20) {
        colmatrix.push(0);
      }
    }
    return (
      <>
        <Button
          icon="pencil-alt"
          onClick={() =>
            act('modify_color_value', {
              name: filterName,
            })
          }
        />
        <Stack>
          {[0, 1, 2, 3].map((col, key) => (
            <Stack.Item key={key}>
              <Stack vertical>
                {[0, 1, 2, 3, 4].map((row, key) => (
                  <Stack.Item key={key}>
                    <Box inline textColor="label" width="2.1rem">
                      {`${prefixes[row]}${prefixes[col]}:`}
                    </Box>
                    <NumberInput
                      value={colmatrix[row * 4 + col]}
                      step={0.01}
                      width="50px"
                      format={(v) => toFixed(v, 2)}
                      onDrag={(v) => {
                        let retColor = colmatrix;
                        retColor[row * 4 + col] = v;
                        act('transition_filter_value', {
                          name: filterName,
                          new_data: {
                            [name]: retColor,
                          },
                        });
                      }}
                      maxValue={Infinity}
                      minValue={-Infinity}
                    />
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
          ))}
        </Stack>
      </>
    );
  } else {
    return (
      <>
        {value.type}
        <Button
          icon="pencil-alt"
          onClick={() =>
            act('modify_color_value', {
              name: filterName,
            })
          }
        />
        <ColorBox color={value} mr={0.5} />
        <Input
          value={value}
          width="90px"
          onInput={(e, value) =>
            act('transition_filter_value', {
              name: filterName,
              new_data: {
                [name]: value,
              },
            })
          }
        />
        <Button
          onClick={() =>
            act('convert_color_value_matrix', {
              name: filterName,
            })
          }
        >
          Convert to color matrix
        </Button>
      </>
    );
  }
};
