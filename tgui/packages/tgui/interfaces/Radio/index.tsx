/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { useBackend } from '../../backend';
import { AnimatedNumber, Box, Button, Knob, LabeledList, Section, Stack, Table } from '../../components';
import { formatFrequency } from '../../format';
import { Window } from '../../layouts';
import { RadioData, RadioWires } from './type';

const MIN_FREQ = 1441;
const MAX_FREQ = 1489;
const MIN_CODE = 1;
const MAX_CODE = 100;

export const Radio = (_props, context) => {
  const { data, act } = useBackend<RadioData>(context);

  const setFrequency = (value: number, finish: boolean) => {
    act('set-frequency', { value, finish });
  };
  const setCode = (value: number, finish: boolean) => {
    act('set-code', { value, finish });
  };


  return (
    <Window width="280" height="400" title={data.name}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <LabeledList>
                {!!data.hasMicrophone && (
                  <LabeledList.Item label="Microphone">
                    <Button.Checkbox checked={data.broadcasting} onClick={() => act('toggle-broadcasting')}>
                      {data.broadcasting ? 'Engaged' : 'Disengaged'}
                    </Button.Checkbox>
                  </LabeledList.Item>
                )}
                <LabeledList.Item label="Speaker">
                  <Button.Checkbox checked={data.listening} onClick={() => act('toggle-listening')}>
                    {data.listening ? 'Engaged' : 'Disengaged'}
                  </Button.Checkbox>
                </LabeledList.Item>
                <LabeledList.Item label="Frequency">
                  <Stack align="center">
                    <Stack.Item>
                      {!data.lockedFrequency && (
                        <Knob
                          animated
                          value={data.frequency}
                          minValue={MIN_FREQ}
                          maxValue={MAX_FREQ}
                          stepPixelSize={2}
                          format={formatFrequency}
                          onDrag={(_e: any, value: number) => setFrequency(value, false)}
                          onChange={(_e: any, value: number) => setFrequency(value, true)}
                        />
                      )}
                    </Stack.Item>
                    <Stack.Item>
                      <AnimatedNumber value={data.frequency} format={formatFrequency} />
                    </Stack.Item>
                  </Stack>
                </LabeledList.Item>
                {!!data.code && (
                  <LabeledList.Item label="Code">
                    <Stack align="center">
                      <Stack.Item>
                        <Knob
                          animated
                          value={data.code}
                          minValue={MIN_CODE}
                          maxValue={MAX_CODE}
                          stepPixelSize={1}
                          onDrag={(_e: any, value: number) => setCode(value, false)}
                          onChange={(_e: any, value: number) => setCode(value, true)}
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <AnimatedNumber value={data.code} />
                      </Stack.Item>
                    </Stack>
                  </LabeledList.Item>
                )}
                {!!data.sendButton && (
                  <LabeledList.Item>
                    <Button align="center" onClick={() => { act("send"); }}>Send signal</Button>
                  </LabeledList.Item>
                )}
              </LabeledList>
            </Section>
          </Stack.Item>
          {data.secureFrequencies.length > 0 && (
            <Stack.Item grow={1}>
              <Section title="Supplementary Channels" fill scrollable>
                <Table>
                  <Table.Row header>
                    <Table.Cell header>Channel</Table.Cell>
                    <Table.Cell header>Frequency</Table.Cell>
                    <Table.Cell header>Prefix</Table.Cell>
                  </Table.Row>
                  {data.secureFrequencies.map((freq) => (
                    <Table.Row key={freq.frequency}>
                      <Table.Cell>{freq.channel}</Table.Cell>
                      <Table.Cell>{freq.frequency}</Table.Cell>
                      <Table.Cell>
                        <Box as="code">{freq.sayToken}</Box>
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              </Section>
            </Stack.Item>
          )}
          {!!data.modifiable && (
            <Stack.Item>
              <Section title="Access Panel">
                <LabeledList>
                  <LabeledList.Item label="Green Wire" labelColor="green">
                    <Button color="green" onClick={() => act('toggle-wire', { wire: RadioWires.Transmit })}>
                      {data.wires & RadioWires.Transmit ? 'Cut' : 'Mend'}
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Red Wire" labelColor="red">
                    <Button color="red" onClick={() => act('toggle-wire', { wire: RadioWires.Receive })}>
                      {data.wires & RadioWires.Receive ? 'Cut' : 'Mend'}
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Blue Wire" labelColor="blue">
                    <Button color="blue" onClick={() => act('toggle-wire', { wire: RadioWires.Signal })}>
                      {data.wires & RadioWires.Signal ? 'Cut' : 'Mend'}
                    </Button>
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
