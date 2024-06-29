/**
 * @file
 * @copyright 2024
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @license MIT
 */
import { useBackend } from '../backend';
import { AnimatedNumber, Knob, LabeledList, Section, Stack } from '../components';
import { formatFrequency } from '../format';
import { Window } from '../layouts';

const MIN_FREQ = 1141;
const MAX_FREQ = 1489;

export const PacketVision = (_props, context) => {
  const { data, act } = useBackend(context);

  const setFrequency = (value, finish) => {
    act('set-frequency', { value, finish });
  };
  return (
    <Window width="280" height="150" title="Packetvision HUD">
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Frequency">
              <Stack align="center">
                <Stack.Item>
                  <Knob
                    animated
                    value={data.frequency}
                    minValue={MIN_FREQ}
                    maxValue={MAX_FREQ}
                    stepPixelSize={2}
                    format={formatFrequency}
                    onDrag={(_, value) => setFrequency(value, false)}
                    onChange={(_, value) => setFrequency(value, true)}
                  />
                </Stack.Item>
                <Stack.Item>
                  <AnimatedNumber value={data.frequency} format={formatFrequency} />
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
