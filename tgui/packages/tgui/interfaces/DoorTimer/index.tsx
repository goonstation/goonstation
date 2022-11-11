/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { useBackend } from '../../backend';
import { Button, Knob, LabeledControls, Section, Stack, TimeDisplay } from '../../components';
import { formatTime } from '../../format';
import { Window } from '../../layouts';
import { DoorTimerData } from './type';

export const DoorTimer = (_props, context) => {
  const { act, data } = useBackend<DoorTimerData>(context);

  return (
    <Window width={260} height={data.flasher ? 279 : 207}>
      <Window.Content>
        <Stack vertical fill justify="stretch">
          <Stack.Item grow={1}>
            <Section title="Timer" fill>
              <LabeledControls justify="start">
                <LabeledControls.Item label="Time">
                  <Stack align="center">
                    <Stack.Item>
                      <Knob
                        animated
                        minValue={0}
                        maxValue={data.maxTime}
                        value={data.time}
                        format={(v) => formatTime(v * 10)}
                        onDrag={(_e: any, time: number) => act('set-time', { time })}
                        onChange={(_e: any, time: number) => act('set-time', { time, finish: true })}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <TimeDisplay value={data.time * 10} timing={data.timing} format={formatTime} />
                    </Stack.Item>
                  </Stack>
                </LabeledControls.Item>
                <LabeledControls.Item>
                  <Button onClick={() => act('toggle-timing')}>{data.timing ? 'Stop' : 'Start'}</Button>
                </LabeledControls.Item>
              </LabeledControls>
            </Section>
          </Stack.Item>
          {!!data.flusher && (
            <Stack.Item>
              <Section title="Floor Flusher" fill>
                <Button
                  onClick={() => act('toggle-flusher')}
                  backgroundColor={data.opening ? 'orange' : undefined}>
                  {data.opening ? (data.flusheropen ? 'Opening...' : 'Closing...') : (data.flusheropen ? 'Close Flusher' : 'Open Flusher')}
                </Button>
              </Section>
            </Stack.Item>
          )}
          {!!data.flasher && (
            <Stack.Item>
              <Section title="Flasher" fill>
                <Button
                  onClick={() => act('activate-flasher')}
                  backgroundColor={data.recharging ? 'orange' : undefined}>
                  Flash Cell {!!data.recharging && '(Recharging)'}
                </Button>
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
