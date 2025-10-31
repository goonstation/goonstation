import {
  AnimatedNumber,
  Box,
  Button,
  Dimmer,
  Icon,
  LabeledList,
  NumberInput,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';

import { useBackend, useLocalState } from '../../backend';
import { formatTime } from '../../format';
import { Window } from '../../layouts';
import type { GameClockData } from './types';

type TeamProps = {
  team: 'white' | 'black';
};

export const Gameclock = () => {
  const { data } = useBackend<GameClockData>();

  const { name } = data.clockStatic;

  const [configModalOpen] = useLocalState('configModalOpen', false);
  const [swap] = useLocalState('swap', false);

  const [helpModalOpen, setHelpModalOpen] = useLocalState(
    'helpModalOpen',
    false,
  );

  const helpButtonClick = !configModalOpen
    ? () => {
        setHelpModalOpen(!helpModalOpen);
      }
    : undefined;

  return (
    <Window title={name} width={220} height={380}>
      <Window.Content className="gameclock__window" fitted>
        {configModalOpen && <ConfigModal />}
        {helpModalOpen && <HelpModal />}
        <Box className="gameclock__help">
          <Button
            className="gameclock__helpbutton"
            tooltip={helpModalOpen ? 'Close' : 'Help'}
            icon={helpModalOpen ? 'xmark' : 'question'}
            color={helpModalOpen && 'orange'}
            onClick={helpButtonClick}
          />
        </Box>
        <TeamIcon team={swap ? 'white' : 'black'} />
        <SidePart team={swap ? 'white' : 'black'} />
        <MidPart />
        <SidePart team={swap ? 'black' : 'white'} />
        <TeamIcon team={swap ? 'black' : 'white'} />
      </Window.Content>
    </Window>
  );
};

const ConfigModal = () => {
  const { data, act } = useBackend<GameClockData>();

  const { defaultTime } = data.clockStatic;

  const [, setConfigModalOpen] = useLocalState('configModalOpen', false);
  const [whiteTimeBuffer, setWhiteTimeBuffer] = useLocalState(
    'whiteTimeBuffer',
    0,
  );
  const [blackTimeBuffer, setBlackTimeBuffer] = useLocalState(
    'blackTimeBuffer',
    0,
  );

  const setTime = (whiteTime, blackTime) => {
    act('set_time', {
      whiteTime: whiteTime * 10,
      blackTime: blackTime * 10,
    });
  };

  return (
    <Dimmer className="gameclock__configmodal">
      <LabeledList>
        <LabeledList.Item label="Time (White)">
          <TimeInput team={'white'} />
        </LabeledList.Item>
        <LabeledList.Item label="Time (Black)">
          <TimeInput team={'black'} />
        </LabeledList.Item>
      </LabeledList>
      <Box className="gameclock__configmodalbuttoncontainer">
        <Button
          onClick={() => {
            setWhiteTimeBuffer(defaultTime);
            setBlackTimeBuffer(defaultTime);
          }}
        >
          Reset to default
        </Button>
        <Button
          onClick={() => {
            setConfigModalOpen(false);
            setTime(whiteTimeBuffer, blackTimeBuffer);
          }}
        >
          Apply
        </Button>
        <Button onClick={() => setConfigModalOpen(false)}>Cancel</Button>
      </Box>
    </Dimmer>
  );
};

const HelpModal = () => {
  return (
    <Dimmer>
      <Section>
        <p>
          <strong>Help</strong>
        </p>
        <p>
          These clocks are used in two-player games where the players move in
          turns.
        </p>
        <p>
          Click on the clock face corresponding to your color to end your turn.
        </p>
        <p>
          The time value (in seconds) for each clock can be set using the Clocks
          Setup button.
        </p>
        <p>
          Before starting the clock, ensure that the Current Turn is set to the
          correct side.
        </p>
        <p>
          The positions of the White and Black clocks can be swapped on your
          client using the rotate view button.
        </p>
      </Section>
    </Dimmer>
  );
};

const TimeInput = (props: TeamProps) => {
  const { data } = useBackend<GameClockData>();

  const { minTime, maxTime } = data.clockStatic;

  const { team } = props;

  const [whiteTimeBuffer, setWhiteTimeBuffer] = useLocalState(
    'whiteTimeBuffer',
    0,
  );
  const [blackTimeBuffer, setBlackTimeBuffer] = useLocalState(
    'blackTimeBuffer',
    0,
  );

  const showTime = (value) => {
    return formatTime(value * 10);
  };

  return (
    <NumberInput
      onChange={(value) => {
        team === 'white'
          ? setWhiteTimeBuffer(value)
          : setBlackTimeBuffer(value);
      }}
      format={showTime}
      value={team === 'white' ? whiteTimeBuffer : blackTimeBuffer}
      minValue={minTime}
      maxValue={maxTime}
      step={15}
      stepPixelSize={2}
    />
  );
};

const TeamIcon = (props: TeamProps) => {
  const { team } = props;

  return (
    <Stack direction={'column'}>
      <Tooltip content={team === 'white' ? 'White' : 'Black'}>
        <Icon
          className="gameclock__teamicon"
          name={`circle${team === 'white' ? '' : '-o'}`}
        />
      </Tooltip>
    </Stack>
  );
};

const SidePart = (props: TeamProps) => {
  const { data, act } = useBackend<GameClockData>();

  const { team } = props;

  const showTime = (value) => {
    return formatTime(value * 10);
  };

  return (
    <Stack direction={'column'} fill className="gameclock__sidepart">
      <Button
        color="orange"
        disabled={
          !data.timing || (data.turn ? team === 'black' : team === 'white')
        }
        className="gameclock__timebutton"
        onClick={() => act('end_turn')}
      >
        <Stack className="gameclock__timeflex">
          <AnimatedNumber
            value={team === 'white' ? data.whiteTime : data.blackTime}
            format={showTime}
          />
        </Stack>
      </Button>
    </Stack>
  );
};

const MidPart = (_) => {
  const { data, act } = useBackend<GameClockData>();

  const [, setConfigModalOpen] = useLocalState('configModalOpen', false);
  const [, setWhiteTimeBuffer] = useLocalState('whiteTimeBuffer', 0);
  const [, setBlackTimeBuffer] = useLocalState('blackTimeBuffer', 0);
  const [swap, toggleSwap] = useLocalState('swap', false);

  return (
    <Stack direction={'row'} className="gameclock__mid">
      <Box>
        <Button
          className="gameclock__utilbutton"
          disabled={data.timing}
          tooltip="Clocks Setup"
          tooltipPosition="top"
          icon="cog"
          onClick={() => {
            setConfigModalOpen(true);
            setWhiteTimeBuffer(data.whiteTime);
            setBlackTimeBuffer(data.blackTime);
          }}
        />
      </Box>
      <Box>
        <Button
          className="gameclock__utilbutton"
          disabled={data.timing}
          tooltip={'Current Turn: ' + (data.turn ? 'White' : 'Black')}
          tooltipPosition="top"
          icon="flag"
          color={data.turn ? 'white' : 'black'}
          onClick={() => act('set_turn')}
        />
      </Box>
      <Box>
        <Button
          className="gameclock__utilbutton"
          disabled={data.whiteTime === 0 || data.blackTime === 0}
          tooltip={data.timing ? 'Pause' : 'Unpause'}
          tooltipPosition="top"
          icon={data.timing ? 'pause' : 'play'}
          color={data.timing ? 'orange' : ''}
          onClick={() => act('toggle_timing')}
        />
      </Box>
      <Box>
        <Button
          className="gameclock__utilbutton"
          tooltip="Rotate view"
          tooltipPosition="top"
          icon="rotate"
          onClick={() => toggleSwap(!swap)}
        />
      </Box>
    </Stack>
  );
};
