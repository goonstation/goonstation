/**
 * @file
 * @copyright 2022
 * @author disturbherb (https://github.com/disturbherb)
 * @license MIT
 */

import { classes } from 'common/react';
import { useBackend } from '../backend';
import { Box, Icon, LabeledList, ProgressBar, Slider, Tooltip } from '../components';
import { Window } from '../layouts';

const MODE_OFF = 0;
const MODE_RECORDING = 1;
const MODE_PLAYING = 2;

export const AudioLog = (props, context) => {
  const { act, data } = useBackend(context);
  const { current_line, memory_capacity, mode, name, occupied_memory, tape } = data;

  return (
    <Window title={name} width={320} height={250}>
      <Window.Content>
        <Box className="audiolog__outerwrapper">
          <Box className={classes(['audiolog__lcdscreen', 'audiolog__labelscreen'])}>
            <LabelScreen />
          </Box>
          <Box className="audiolog__lcdscreen">
            <LabeledList>
              <LabeledList.Item label="MEMORY" labelColor="white" className="audiolog__monospaced">
                <ProgressBar
                  ranges={{
                    good: [0, 0.5],
                    average: [0.5, 0.75],
                    bad: [0.75, 1.0],
                  }}
                  value={tape ? occupied_memory / memory_capacity : 0}
                />
              </LabeledList.Item>
              <LabeledList.Item label="LINE" labelColor="white" className="audiolog__monospaced">
                {mode === MODE_OFF ? (
                  <Slider
                    animated
                    color="good"
                    minValue={1}
                    maxValue={occupied_memory}
                    value={tape ? current_line : 1}
                    onChange={(value) => act('scrub_to', { line: value })}
                  />
                ) : (
                  <ProgressBar color="good" minValue={1} maxValue={occupied_memory} value={tape ? current_line : 0}>
                    {current_line}
                  </ProgressBar>
                )}
              </LabeledList.Item>
            </LabeledList>
          </Box>
          <Box className="audiolog__buttonrow">
            <PushButton isRed index="record" tooltip="Record" iconName="circle" keepDown={mode === MODE_RECORDING ? true : false} />
            <PushButton index="play" tooltip="Play" iconName="play" keepDown={mode === MODE_PLAYING ? true : false} />
            <PushButton index="rewind" tooltip="Rewind" iconName="backward" />
            {/* <PushButton index="loop" tooltip="Loop" iconName="repeat" /> */}
            <PushButton index="stop" tooltip="Stop" iconName="square" />
            <PushButton index="clear" tooltip="Clear" iconName="trash" />
            <PushButton index="eject" tooltip="Eject" iconName="eject" />
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};

const LabelScreen = (_, context) => {
  const { data } = useBackend(context);
  const { mode, tape, tape_name } = data;

  const renderLabel = () => {
    if (tape) {
      switch (mode) {
        case MODE_OFF:
          return <marquee>LOADED TAPE: {tape_name}</marquee>;
        case MODE_RECORDING:
          return 'RECORDING';
        case MODE_PLAYING:
          return <marquee>PLAYING: {tape_name}</marquee>;
      }
    } else {
      return 'INSERT TAPE';
    }
  };

  return renderLabel();
};

const PushButton = (props, context) => {
  const { act } = useBackend(context);

  const { iconName, index, isRed, keepDown, tooltip } = props;

  const keyColour = isRed ? 'audiolog__buttonelement-red' : 'audiolog__buttonelement-black';

  return (
    <Tooltip content={tooltip} position="top">
      <Box
        className={classes([
          'audiolog__buttonelement',
          keyColour,
          (keepDown && (
            isRed ? 'audiolog__buttonelement-red-active'
              : 'audiolog__buttonelement-black-active')),
        ])}
        onMouseDown={!keepDown && (() => act(index))}>
        <Icon className="fa-fw" name={iconName} color={keepDown && "gray"} />
      </Box>
    </Tooltip>
  );
};
