/**
 * Copyright (c) 2025 @Azrun
 * SPDX-License-Identifier: MIT
 */

import { useState } from 'react';
import {
  Button,
  Collapsible,
  Dropdown,
  Flex,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Tooltip,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { DataInputOptions } from './common/DataInput';

type AnimationEditorData = {
  target: string;
  valid_keys: Array<string>;
  steps: Array<AnimationStepType>;
  easing_options: EnumMapping;
  easing_flags: EnumMapping;
  flags: EnumMapping;
};

type AnimationStepType = {
  name: string;
  var_list: Array<AnimationVars>;
  time: number;
  loop: number;
  easing: number;
  flags: number;
};

type AnimationVars = {
  [key: string]: number | string;
};

type EnumMapping = {
  [key: string]: number;
};

interface AnimationStepProps {
  key?: string | number;
  index: number;
  valid_keys: Array<string>;
  step: AnimationStepType;
  max_steps?: number;
  easing_options: EnumMapping;
  easing_flags: EnumMapping;
  flags: EnumMapping;
}

interface AnimationFlagProps {
  index: number;
  value: number;
  flags: EnumMapping;
}

const flagsToolTipMap = {
  ANIMATION_END_NOW:
    'Normally if you interrupt another animation, it transitions from its current state. This flag will start the new animation fresh by bringing the old one to its conclusion immediately. It is only meaningful on the first step of a new animation. If using the tag argument, only a previous sequence with the same matching tag is stopped.',
  ANIMATION_LINEAR_TRANSFORM:
    'The transform var is interpolated in a way that preserves size during rotation, by pulling the rotation step out. This flag forces linear interpolation, which may be more desirable for things like beam effects, mechanical arms, etc. ',
  ANIMATION_PARALLEL:
    'Start a parallel animation sequence that runs alongside the current animation sequence. The difference between where the parallel sequence started, and its current appearance, is added to the result of any previous animations. For instance, you could use this to animate pixel_y separately from pixel_x with different timing and easing. You could also use this to apply a rotational transform after a previous animation sequence did a translate. (When using this flag, the src var may be included, but it is optional.) This flag is implied if using the tag argument for a named sequence. ',
  ANIMATION_RELATIVE:
    'The vars specified are relative to the current state. This works for maptext_x/y/width/height, pixel_x/y/w/z, luminosity, layer, alpha, transform, and color. For transform and color, the current value is multiplied by the new one. Vars not in this list are simply changed as if this flag is not present. (If you supply an appearance instead of individual vars, this flag is meaningless.) ',
  ANIMATION_CONTINUE:
    'This flag is equivalent to leaving out the Object argument. It exists to make it easier to define an animation using a for loop. If Object differs from the previous sequence, this flag will be ignored and a new sequence will start.',
  ANIMATION_SLICE:
    'Following a series of animate() calls, you can view just a portion of the animation by using animate(object, delay=start, time=duration, flags=ANIMATION_SLICE). The loop parameter may optionally be included. The delay is the start time of the slice, relative to the beginning of all the active animations on the object. (That is, earlier animations that have concluded will not be included.) You can call the proc again with a different slice if you want to see a different portion of the animation. A negative value for time will remove the slice and finish any existing animations.',
  ANIMATION_END_LOOP:
    'Tells previous animation sequences to stop looping and end naturally. The delay for starting this new sequence is adjusted based on that. If using the tag argument, only a previous sequence with the same matching tag is told to stop looping.',
};

const stepToolTipMap = {
  time: 'Duration of the step in ticks (1 tick = 0.1 seconds)',
  loop: 'Number of times to loop this step (-1 for infinite)',
  easing: 'Easing function to use for this step',
  flags: 'Additional flags to modify the behavior of this step',
};

const AnimationVarsToolTipMap = {
  alpha: `Controls the opacity of the icon displayed on players' screens. Alpha is also applied to maptext. [0-255]`,
  color: 'The color object (as a hex string, e.g. #RRGGBB) of the object',
  glide_size:
    'This controls the number of pixels an object is moved in each footstep during animated movement. The default value of 0 chooses automated control over this value, which generally results in a minimum footstep of 4 pixels that is increased when necessary to keep up with motion on the turf grid.',
  infra_luminosity:
    'This causes the object to be visible in the dark to mobs that can see infrared light. Nothing but the object itself is lit up by the infrared emission. The scale is identical to luminosity: 1 makes it visible only from the same location; 2 makes it visible from a neighboring position; and so on.',
  layer:
    'This numerical value determines the layer in which the object is drawn on the map.',
  maptext_width: 'This is the width of the text shown in the maptext var',
  maptext_height: 'This is the height of the text shown in the maptext var.',
  maptext_y: 'Maptext, if used, is offset by this many pixels upward.',
  maptext_x: 'Maptext, if used, is offset by this many pixels to the right.',
  luminosity: `This sets the object's luminosity (how far it casts light). It must be an integer in the range 0 to 6`,
  pixel_x: `Displaces the object's icon on the x-axis by the specified number of pixels.`,
  pixel_y: `Displaces the object's icon on the y-axis by the specified number of pixels.`,
  pixel_w: `This displaces the object's icon horizontally by the specified number of pixels. Used in siometric and side-view displays.`,
  pixel_z: `This displaces the object's icon vertically by the specified number of pixels. Used in isometric and side-view displays.`,
  transform: 'The transform matrix of the object',
  dir: 'The direction the object is facing',
  icon: 'The icon of the object',
  icon_state: 'The icon_state of the object',
  invisibility: `Determines the object's level of invisibility.`,
  maptext: 'The maptext of the object',
  suffix: `This is an optional text string that follows the object's name in the stat panels. For example, items in an inventory list are displayed as an icon, a name, and a suffix.`,
};

const AnimationFlags = (props: AnimationFlagProps) => {
  const { act } = useBackend();

  return (
    <>
      <Dropdown
        displayText="Add Flag..."
        options={Object.keys(props.flags)}
        selected={null}
        onSelected={(value) =>
          act('update_step', {
            index: props.index,
            field: 'flags',
            value: props.flags[value] | props.value,
          })
        }
      />
      {Object.keys(props.flags).map((flag) =>
        (props.flags[flag] & props.value) !== 0 ? (
          <Button
            key={flag}
            tooltip={flagsToolTipMap[flag]}
            selected={(props.flags[flag] & props.value) !== 0}
            onClick={() =>
              act('update_step', {
                index: props.index,
                field: 'flags',
                value: props.value ^ props.flags[flag],
              })
            }
          >
            {flag}
          </Button>
        ) : null,
      )}
    </>
  );
};

const AnimationStepsToString = (
  steps: Array<AnimationStepType>,
  easingOptions: EnumMapping,
  easing_flags: EnumMapping,
  flags: EnumMapping,
) => {
  function stepToString(index: number, step: AnimationStepType) {
    let str = 'animate(';
    if (index === 0) {
      str += 'target, ';
    }
    str += `time=${step.time}, `;

    if (step.loop !== 0) {
      str += `loop=${step.loop}, `;
    }
    if (step.easing !== 0) {
      str += `easing=${
        Object.entries(easingOptions).find(
          ([key, value]) => value === (step.easing & 0x3f),
        )?.[0]
      }`;
    }
    if ((step.easing & 0x3f) !== 0) {
      if ((easing_flags['EASE_IN'] & step.easing) !== 0) {
        str += ' | EASE_IN';
      }
      if ((easing_flags['EASE_OUT'] & step.easing) !== 0) {
        str += ' | EASE_OUT';
      }
      str += ', ';
    }

    if (step.flags !== 0) {
      str += `flags=`;
      for (let [key, value] of Object.entries(flags)) {
        if ((value & step.flags) !== 0) {
          str += `${key} | `;
        }
      }
      str = str.slice(0, -3); // Remove trailing ' | '
      str += ', ';
    }

    for (let [key, value] of Object.entries(step.var_list)) {
      if (typeof value === 'string') {
        str += `${key}="${value}", `;
      } else {
        str += `${key}=${value}, `;
      }
    }
    str = str.slice(0, -2); // Remove trailing ', '
    str += ')\r\n';

    return str;
  }

  return steps.map((step, index) => (
    <>
      {stepToString(index, step)}
      <br />
    </>
  ));
};

interface EasingInputProps {
  index: number;
  value: number;
  easing_options: EnumMapping;
  easing_flags: EnumMapping;
}

const EasingInput = (props: EasingInputProps) => {
  const { act } = useBackend();
  return (
    <>
      <Dropdown
        options={Object.keys(props.easing_options)}
        selected={
          Object.entries(props.easing_options).find(
            ([key, value]) => value === (props.value & 0x3f),
          )?.[0] || 'Unknown'
        }
        onSelected={(value) =>
          act('update_step', {
            index: props.index,
            field: 'easing',
            value: props.easing_options[value] | (props.value & ~0x3f),
          })
        }
      />
      {(props.value & 0x3f) !== 0 ? (
        <>
          <Button
            selected={(props.easing_flags['EASE_IN'] & props.value) !== 0}
            onClick={() =>
              act('update_step', {
                index: props.index,
                field: 'easing',
                value: props.value ^ props.easing_flags['EASE_IN'],
              })
            }
          >
            In
          </Button>
          <Button
            selected={(props.easing_flags['EASE_OUT'] & props.value) !== 0}
            onClick={() =>
              act('update_step', {
                index: props.index,
                field: 'easing',
                value: props.value ^ props.easing_flags['EASE_OUT'],
              })
            }
          >
            Out
          </Button>
          <EasingSample easing={props.value} />
        </>
      ) : null}
    </>
  );
};

interface EasingSampleProps {
  easing: number;
}

const EasingSample = (props: EasingSampleProps) => {
  type Point = {
    x: number;
    y: number;
  };

  /*
   # Original source: https://www.byond.com/docs/ref/
   # Author: Lummox JR
   # Modified to include error handling for edge cases.
   */
  function easing(
    time: number,
    ease: number,
    doubled: boolean = false,
  ): number {
    let _in = (ease & 64) !== 0,
      _out = (ease & 128) !== 0,
      b;
    ease &= 63;
    time = Math.max(0, Math.min(1, time)); // clamp t
    if (!ease) return time; // linear case, simplest of all
    if (!_in && !_out) {
      // default case
      switch (ease) {
        case 4:
        case 5:
        case 8:
          _out = true;
          break; // bounce, elastic, jump
        default:
          _in = _out = true;
          break; // all other cases
      }
    }
    if (_in && _out) {
      if (ease === 8) return time <= 0.5 ? 0 : 1; // jump is a special case
      return (
        (time <= 0.5
          ? easing(time * 2, ease | 64, true)
          : easing(time * 2 - 1, ease | 128, true) + 1) / 2
      );
    }
    if (_in) return 1 - easing(1 - time, ease | 128, doubled);
    switch (
      ease // all out cases
    ) {
      case 1: // sine
        return Math.sin((time * Math.PI) / 2);
      case 2: // circular
        time = 1 - time;
        return Math.sqrt(1 - time * time);
      case 3: // cubic
        time = 1 - time;
        return 1 - time * time * time;
      case 4: // bounce
        b = time * 2.75;
        if (b < 1) return b * b; // 1st arc
        if (b < 2) {
          b -= 1.5;
          return b * b + 0.75;
        } // bounce #1
        if (b < 2.5) {
          b -= 2.25;
          return b * b + 0.9375;
        } // bounce #2
        b -= 2.625;
        return b * b + 0.984375; // final bounce
      case 5: // elastic
        return 1 - Math.pow(2, -10 * time) * Math.cos((time * Math.PI) / 0.15);
      case 6: // back
        b = doubled ? 2.59491 : 1.70158;
        time = 1 - time;
        return 1 - time * time * ((b + 1) * time - b);
      case 7: // quad
        time = 1 - time;
        return 1 - time * time;
      case 8: // jump
        return time < 1 ? 0 : 1;
      default:
        return time;
    }
  }

  function generateEasingCurve(ease: number) {
    const points: Point[] = [];
    const numPoints = 100;
    for (let i = 0; i <= numPoints; i++) {
      const t = i / numPoints;
      const easedValue = easing(t, ease, false);
      points.push({ x: t * 50, y: 50 - easedValue * 50 });
    }
    return points;
  }

  let pathData = generateEasingCurve(props.easing)
    .map((point, index) =>
      index === 0 ? `M ${point.x} ${point.y}` : `L ${point.x} ${point.y}`,
    )
    .join(' ');

  return props.easing ? (
    <svg width="50" height="50">
      <rect
        x={0}
        y={0}
        width={50}
        height={50}
        fill="white"
        fill-opacity="0.4"
      />
      <text x={10} y={49} font-size={10} fill="blue">
        Time→
      </text>
      <path d={pathData} style={{ fill: 'none', stroke: 'black' }} />
    </svg>
  ) : null;
};

const AnimationStep = (props: AnimationStepProps) => {
  const { act } = useBackend();

  return (
    <Collapsible
      key={props.key}
      title={`Step ${props.index + 1}`}
      open
      buttons={
        <>
          <Button
            icon="angle-down"
            tooltip="Move Step Down"
            disabled={
              props.index === undefined ||
              (props.max_steps !== undefined &&
                props.index >= props.max_steps - 1)
            }
            onClick={() =>
              act('move_step', {
                index: props.index,
                new_index: props.index + 1,
              })
            }
          />
          <Button
            icon="angle-up"
            tooltip="Move Step Up"
            disabled={props.index <= 0}
            onClick={() =>
              act('move_step', {
                index: props.index,
                new_index: props.index - 1,
              })
            }
          />
          <Button
            icon="trash"
            color="red"
            tooltip="Delete Step"
            onClick={() => act('delete_step', { index: props.index })}
          />
        </>
      }
    >
      <Flex>
        <Flex.Item>
          <Section title="Step Settings">
            <LabeledList>
              <LabeledList.Item label="Duration">
                <Tooltip content={stepToolTipMap['time']} position="bottom">
                  <NumberInput
                    value={props.step.time / 10}
                    format={(value) => toFixed(value, 1)}
                    minValue={0}
                    maxValue={99999}
                    width="60px"
                    step={1}
                    unit=" sec"
                    onChange={(value) =>
                      act('update_step', {
                        index: props.index,
                        field: 'time',
                        value: value * 10,
                      })
                    }
                  />
                  {null}
                </Tooltip>
              </LabeledList.Item>

              <LabeledList.Item label="Loop">
                <Tooltip content="Number of times to loop (-1 for infinite)">
                  <NumberInput
                    value={props.step.loop}
                    minValue={-1}
                    maxValue={99999}
                    width="60px"
                    step={1}
                    onChange={(value) =>
                      act('update_step', {
                        index: props.index,
                        field: 'loop',
                        value,
                      })
                    }
                  />
                  {null}
                </Tooltip>
              </LabeledList.Item>
              <LabeledList.Item label="Easing">
                {props.step.easing !== null ? (
                  <EasingInput
                    value={props.step.easing}
                    index={props.index}
                    easing_flags={props.easing_flags}
                    easing_options={props.easing_options}
                  />
                ) : (
                  'Easing Not Found'
                )}
              </LabeledList.Item>

              <LabeledList.Item label="Flags">
                {props.step.flags !== null ? (
                  <AnimationFlags
                    value={props.step.flags}
                    index={props.index}
                    flags={props.flags}
                  />
                ) : (
                  'Flags Not Found'
                )}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Flex.Item>
        <Flex.Item grow={1} ml={2}>
          <Section title="Variables">
            <LabeledList>
              <LabeledList.Item label="New Var">
                <Dropdown
                  selected={null}
                  options={props.valid_keys}
                  onSelected={(value) =>
                    act('add_step_var', {
                      index: props.index,
                      key: value,
                    })
                  }
                />
              </LabeledList.Item>
              {Object.keys(props.step.var_list).map((key) => (
                <LabeledList.Item label={key} key={key}>
                  <Tooltip
                    content={AnimationVarsToolTipMap[key]}
                    position="bottom"
                  >
                    <Input
                      width="70%"
                      value={String(props.step.var_list[key])}
                      onChange={(value) =>
                        act('update_step_var', {
                          index: props.index,
                          key: key,
                          value: Number(value) || value,
                        })
                      }
                    />
                  </Tooltip>
                  <Button
                    icon="trash"
                    color="red"
                    ml={1}
                    tooltip="Delete Variable"
                    onClick={() =>
                      act('delete_step_var', { index: props.index, key: key })
                    }
                  />
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Flex.Item>
      </Flex>
    </Collapsible>
  );
};

export const AnimationEditor = () => {
  const { data, act } = useBackend<AnimationEditorData>();
  const [importValue, setImportValue] = useState('');

  return (
    <Window title="Animation Editor" width={700} height={800}>
      <Window.Content scrollable>
        <Section title={`Target: ${data.target}`}>
          <DataInputOptions
            options={{
              time: {
                name: 'target',
                type: 'Ref',
                description: 'Target',
                value: data.target,
              },
            }}
          />
        </Section>
        <Section title="Animation Steps">
          {data.steps.length ? (
            data.steps.map((step, index) => (
              <AnimationStep
                key={index}
                index={index}
                step={step}
                valid_keys={data.valid_keys}
                max_steps={data.steps.length}
                easing_flags={data.easing_flags}
                easing_options={data.easing_options}
                flags={data.flags}
              />
            ))
          ) : (
            <Section>No Animation Steps Found</Section>
          )}

          <div style={{ display: 'flex', alignItems: 'center' }}>
            <Button
              icon="plus"
              tooltip="Add Step"
              onClick={() => act('add_step')}
            >
              Add Step
            </Button>
          </div>
        </Section>

        <Section>
          <Button
            fluid
            icon="play"
            color="green"
            disabled={!data.target}
            onClick={() => act('play_animation')}
          >
            Play Animation
          </Button>
        </Section>

        <Section title="Import/Export">
          <Collapsible title="Export">
            <NoticeBox>
              BYOND:
              <br />
              {AnimationStepsToString(
                data.steps,
                data.easing_options,
                data.easing_flags,
                data.flags,
              )}
              <br />
              JSON:
              <br />
              {JSON.stringify(data.steps)}
            </NoticeBox>
          </Collapsible>
          <Collapsible title="Import">
            <Input width="80%" value={importValue} onChange={setImportValue} />
            <Button
              icon="upload"
              color="red"
              ml={1}
              disabled={importValue?.length === 0}
              onClick={() => act('import_steps', { data: importValue })}
            >
              Import Steps
            </Button>
          </Collapsible>
        </Section>
      </Window.Content>
    </Window>
  );
};
