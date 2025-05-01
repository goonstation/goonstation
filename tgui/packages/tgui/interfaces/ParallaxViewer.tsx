/**
 * Copyright (c) 2024 @Azrun
 * SPDX-License-Identifier: MIT
 */

import { BooleanLike } from 'common/react';
import {
  Box,
  Button,
  Collapsible,
  ColorBox,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface ParallaxSourceProps {
  byondRef: string;
  icon: string;
  icon_state: string;
  value: number;
  tessellate: BooleanLike;
  scroll_speed: number;
  scroll_angle: number;
  x: number;
  y: number;
  static_colour: BooleanLike;
  color;
}

interface ParallaxGroupProps {
  group_key: string;
  sources: Array<ParallaxSourceProps>;
}

type ParallaxGroupType = {
  sources: Array<ParallaxSourceProps>;
};

interface ParallaxTypeProps {
  groups: Array<ParallaxGroupType>;
}

type ParallaxViewerData = {
  z_level: Array<ParallaxGroupType>;
  areas: Array<ParallaxGroupType>;
  planets: Array<ParallaxGroupType>;
};

interface ColorMatrixProps {
  byondRef: string;
  group_key: string;
  color;
}

const ColorMatrix = (props: ColorMatrixProps) => {
  const { act } = useBackend();
  const prefixes = ['r', 'g', 'b', 'a', 'c'];
  let colmatrix = props.color;
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
                    act('modify', {
                      byondRef: props.byondRef,
                      group: props.group_key,
                      type: 'color',
                      value: retColor,
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
  );
};

const ParallaxSources = (props: ParallaxGroupProps) => {
  const { act } = useBackend();

  return Object.entries(props.sources).map(
    ([source_key, sourceData], index) => (
      <LabeledList.Item
        key={source_key}
        label={source_key}
        buttons={
          <Button
            icon="delete-left"
            onClick={() =>
              act('delete', {
                group: props.group_key,
                source: source_key,
              })
            }
          />
        }
      >
        <Collapsible>
          <LabeledList>
            <LabeledList.Item label="icon">
              <Button
                icon="pencil-alt"
                tooltip="Select new icon"
                onClick={() =>
                  act('modify_icon', {
                    byondRef: sourceData.byondRef,
                    group: props.group_key,
                    type: 'icon',
                    value: '',
                  })
                }
              />
              <Box inline ml={1}>
                {sourceData.icon}
              </Box>
            </LabeledList.Item>

            <LabeledList.Item label="icon_state">
              <Input
                value={sourceData.icon_state}
                width="250px"
                onChange={(value) =>
                  act('modify', {
                    byondRef: sourceData.byondRef,
                    group: props.group_key,
                    type: 'icon_state',
                    value: value,
                  })
                }
              />
            </LabeledList.Item>

            <LabeledList.Item label="value">
              <NumberInput
                value={sourceData.value}
                minValue={-2}
                maxValue={2}
                // stepPixelSize={4}
                step={0.1}
                width="80px"
                onDrag={(value) =>
                  act('modify', {
                    byondRef: sourceData.byondRef,
                    group: props.group_key,
                    type: 'parallax_value',
                    value: value,
                  })
                }
              />
            </LabeledList.Item>

            <LabeledList.Item label="Tessellate">
              <Button.Checkbox
                checked={sourceData.tessellate}
                icon="cubes"
                onClick={() =>
                  act('modify', {
                    byondRef: sourceData.byondRef,
                    group: props.group_key,
                    type: 'tessellate',
                    value: !sourceData.tessellate,
                  })
                }
              />
            </LabeledList.Item>

            {sourceData.tessellate ? (
              <>
                <LabeledList.Item label="scroll_speed">
                  <NumberInput
                    value={sourceData.scroll_speed}
                    minValue={-900}
                    maxValue={900}
                    step={1}
                    width="80px"
                    onDrag={(value) =>
                      act('modify', {
                        byondRef: sourceData.byondRef,
                        group: props.group_key,
                        type: 'scroll_speed',
                        value: value,
                      })
                    }
                  />
                </LabeledList.Item>

                <LabeledList.Item label="scroll_angle">
                  <NumberInput
                    value={sourceData.scroll_angle}
                    minValue={0}
                    maxValue={360}
                    step={1}
                    width="80px"
                    onDrag={(value) =>
                      act('modify', {
                        byondRef: sourceData.byondRef,
                        group: props.group_key,
                        type: 'scroll_angle',
                        value: value,
                      })
                    }
                  />
                </LabeledList.Item>
              </>
            ) : (
              ''
            )}

            <LabeledList.Item label="initial_x">
              <NumberInput
                value={sourceData.x}
                minValue={-600}
                maxValue={600}
                // stepPixelSize={4}
                step={1}
                width="80px"
                onDrag={(value) =>
                  act('modify', {
                    byondRef: sourceData.byondRef,
                    group: props.group_key,
                    type: 'initial_x',
                    value: value,
                  })
                }
              />
            </LabeledList.Item>

            <LabeledList.Item label="initial_y">
              <NumberInput
                value={sourceData.y}
                minValue={-600}
                maxValue={600}
                // stepPixelSize={4}
                step={1}
                width="80px"
                onDrag={(value) =>
                  act('modify', {
                    byondRef: sourceData.byondRef,
                    group: props.group_key,
                    type: 'initial_y',
                    value: value,
                  })
                }
              />
            </LabeledList.Item>

            <LabeledList.Item label="Static Colour">
              <Button.Checkbox
                checked={sourceData.static_colour}
                onClick={() =>
                  act('modify', {
                    byondRef: sourceData.byondRef,
                    group: props.group_key,
                    type: 'static_colour',
                    value: !sourceData.static_colour,
                  })
                }
              />
            </LabeledList.Item>

            <LabeledList.Item label="color">
              <Button
                icon="pencil-alt"
                onClick={() =>
                  act('modify_color', {
                    byondRef: sourceData.byondRef,
                    group: props.group_key,
                    type: 'color_picker',
                    value: sourceData.color,
                  })
                }
              />
              {Array.isArray(sourceData.color) ? (
                <ColorMatrix
                  byondRef={sourceData.byondRef}
                  group_key={props.group_key}
                  color={sourceData.color}
                />
              ) : (
                <>
                  {' '}
                  <ColorBox color={sourceData.color} mr={0.5} />
                  <Input
                    value={sourceData.color}
                    width="90px"
                    onChange={(value) =>
                      act('modify', {
                        byondRef: sourceData.byondRef,
                        group: props.group_key,
                        type: 'color',
                        value: value,
                      })
                    }
                  />
                  <Button
                    icon="table-cells"
                    tooltip="Convert to Matrix"
                    onClick={() =>
                      act('modify', {
                        byondRef: sourceData.byondRef,
                        group: props.group_key,
                        type: 'color_to_matrix',
                        value: sourceData.color,
                      })
                    }
                  />
                </>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Collapsible>
      </LabeledList.Item>
    ),
  );
};

const ParallaxTypeView = (props: ParallaxTypeProps) => {
  const { act } = useBackend();

  return Object.entries(props.groups).map(([group_key, groupData], index) => (
    <Section
      key={group_key}
      title={group_key}
      buttons={
        <>
          <Button
            icon="window-restore"
            tooltip="Restore layer to defaults"
            onClick={() => act('default', { group: group_key })}
          >
            Defaults
          </Button>
          <Button
            icon="wand-magic-sparkles"
            tooltip="Add Parallax Effect"
            onClick={() => act('canned', { group: group_key })}
          />
          <Button
            icon="plus"
            onClick={() => act('add', { group: group_key })}
            tooltip="Add new layer"
          >
            Add
          </Button>
        </>
      }
    >
      <ParallaxSources group_key={group_key} sources={groupData.sources} />
    </Section>
  ));
};

export const ParallaxViewer = () => {
  const { data } = useBackend<ParallaxViewerData>();

  return (
    <Window title="Parallax Viewer" width={1600} height={800}>
      <Window.Content scrollable>
        <Collapsible title="Z Level">
          <LabeledList>
            <ParallaxTypeView groups={data.z_level} />
          </LabeledList>
        </Collapsible>

        <Collapsible title="Areas">
          <LabeledList>
            <ParallaxTypeView groups={data.areas} />
          </LabeledList>
        </Collapsible>
      </Window.Content>
    </Window>
  );
};
