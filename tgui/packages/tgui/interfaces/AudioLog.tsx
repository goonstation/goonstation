import { BooleanLike, classes } from 'common/react';
import { useBackend } from '../backend';
import { Box, Icon, LabeledList, ProgressBar, Slider, Tooltip } from '../components';
import { Window } from '../layouts';

type AudioLogData = {
  name: string;
  continuous: BooleanLike;
  memory_capacity: number;
  mode: number;
  occupied_memory: number;
}

export const AudioLog = (props, context) => {

  const { act, data } = useBackend<AudioLogData>(context);
  const { continuous, memory_capacity, mode, name, occupied_memory } = data;

  return (
    <Window title={name} width={320} height={200}>
      <Window.Content>
        <Box className="audiolog__outerwrapper">
          <Box className="audiolog__progressbarwrapper">
            <LabeledList>
              <LabeledList.Item label="Memory" labelColor="white">
                <ProgressBar
                  ranges={{
                    good: [0, 0.5],
                    average: [0.5, 0.75],
                    bad: [0.75, 1.0],
                  }}
                  value={occupied_memory/memory_capacity} />
              </LabeledList.Item>
              <LabeledList.Item label="Progress" labelColor="white">
                <Slider />
              </LabeledList.Item>
            </LabeledList>
          </Box>
          <Box className="audiolog__buttonrow">
            <PushButton index="Record" isRed iconName="circle" />
            <PushButton index="Play" iconName="play" />
            <PushButton index="Stop" iconName="square" />
            <PushButton index="Rewind" iconName="backward" />
            <PushButton index="Loop" iconName="repeat" />
            <PushButton index="Clear" iconName="trash" />
            <PushButton index="Eject" iconName="eject" />
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};

const PushButton = (props) => {

  const { iconName, index, isRed } = props;

  const keyColour = isRed && 'audiolog__buttonelement-red';

  return (
    <Tooltip content={index} position="top">
      <Box className={classes([
        'audiolog__buttonelement',
        keyColour,
      ])}>
        <Icon name={iconName} />
      </Box>
    </Tooltip>
  );
};
