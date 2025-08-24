import {
  AnimatedNumber,
  Button,
  Knob,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { formatTime } from '../format';
import { Window } from '../layouts';

const MAX_TIME = 600;

interface TimerData {
  armButton;
  armed;
  minTime;
  name;
  time;
  timing;
}

export const Timer = () => {
  const { data, act } = useBackend<TimerData>();
  const setTime = (value) => {
    act('set-time', { value: value * 10 });
  };

  const showTime = (value) => {
    return formatTime(value * 10);
  };

  return (
    <Window width={280} height={200} title={data.name}>
      <Window.Content>
        <Section>
          <LabeledList>
            {!!data.armButton && (
              <LabeledList.Item label="Armed">
                <Button.Checkbox
                  checked={data.armed}
                  onClick={() => act('toggle-armed')}
                >
                  {data.armed ? 'Armed' : 'Not armed'}
                </Button.Checkbox>
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Timing">
              <Button.Checkbox
                checked={data.timing}
                onClick={() => act('toggle-timing')}
              >
                {data.timing ? 'Timing' : 'Not timing'}
              </Button.Checkbox>
            </LabeledList.Item>
            <LabeledList.Item label="Time">
              <Stack align="center">
                <Stack.Item>
                  <Knob
                    animated
                    value={data.time}
                    minValue={data.minTime}
                    maxValue={MAX_TIME}
                    stepPixelSize={1}
                    format={showTime}
                    onDrag={(_e, value) => setTime(value)}
                    onChange={(_e, value) => setTime(value)}
                  />
                </Stack.Item>
                <Stack.Item>
                  <AnimatedNumber value={data.time} format={showTime} />
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
