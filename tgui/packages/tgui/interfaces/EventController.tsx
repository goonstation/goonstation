/**
 * Copyright (c) 2024 @Azrun
 * SPDX-License-Identifier: MIT
 */

import { numberOfDecimalDigits } from 'common/math';
import { useState } from 'react';
import {
  Button,
  Flex,
  LabeledList,
  NumberInput,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { capitalize } from './common/stringUtils';

interface StorytellerData {
  path: string;
  name: string;
  description: string;
}

interface RoundStartData {
  byondRef: string;
  name: string;
}

interface QueuedEventData {
  queueID: string;
  category: string;
  name: string;
  time: number;
}

const QueuedEvent = (props: QueuedEventData) => {
  const { act } = useBackend<EventControllerData>();
  return (
    <Stack align="left">
      <Stack.Item grow>{props.name}</Stack.Item>
      <Stack.Item>{getMinutes(props.time)} Min</Stack.Item>
      <Stack.Item>
        <Button
          icon="delete-left"
          tooltip="Unschedule"
          color="bad"
          onClick={() =>
            act('unschedule_event', {
              name: props.name,
              id: props.queueID,
              category: props.category,
            })
          }
        />
      </Stack.Item>
    </Stack>
  );
};

interface QueuedSectionProps {
  queueData: Array<QueuedEventData>;
}

const sortEventQueue = (a: QueuedEventData, b: QueuedEventData) =>
  a.time - b.time;

const QueuedSection = (props: QueuedSectionProps) => {
  const sortedQueue = [...props.queueData].sort(sortEventQueue);

  return (
    <Section title="Scheduled Events">
      <Flex direction="column">
        {sortedQueue.length ? (
          sortedQueue.map((queuedEvent, i) => (
            <Flex.Item mb={1} key={i}>
              <QueuedEvent {...queuedEvent} />
            </Flex.Item>
          ))
        ) : (
          <Flex.Item>None</Flex.Item>
        )}
      </Flex>
    </Section>
  );
};

interface RoundStartProps {
  roundStartData: Array<RoundStartData>;
}

const RoundStartSection = (props: RoundStartProps) => {
  const { act } = useBackend();
  return (
    <Section title="Round Start Events">
      <Flex direction="column">
        {props.roundStartData.length ? (
          props.roundStartData.map((startEvent, i) => (
            <Flex.Item mb={1} key={i}>
              <Stack align="left">
                <Stack.Item grow>{startEvent.name}</Stack.Item>
                <Stack.Item>
                  <Button
                    icon="delete-left"
                    tooltip="Unschedule"
                    color="bad"
                    onClick={() =>
                      act('remove_roundstart_event', {
                        name: startEvent.name,
                        ref: startEvent.byondRef,
                      })
                    }
                  />
                </Stack.Item>
              </Stack>
            </Flex.Item>
          ))
        ) : (
          <Flex.Item>None</Flex.Item>
        )}
      </Flex>
    </Section>
  );
};

interface EventData {
  byondRef: string;
  name: string;
  customizable: BooleanLike;
  alwaysCustom: BooleanLike;
  available: BooleanLike;
  enabled: BooleanLike;
}

const getMinutes = (time: number) => {
  return time / 60 / 10;
};

const toMinutes = (time: number) => {
  return time * 60 * 10;
};

const getEventIconColor = (enabled: BooleanLike, active: BooleanLike) => {
  if (enabled) {
    if (active) {
      return 'green';
    } else {
      return 'grey';
    }
  } else {
    return 'red';
  }
};

const getEventIconToolTip = (enabled: BooleanLike, active: BooleanLike) => {
  if (enabled) {
    if (active) {
      return 'Active';
    } else {
      return 'Enabled';
    }
  } else {
    return 'Disabled';
  }
};

const Event = (props: EventData) => {
  const { act } = useBackend();
  return (
    <Stack>
      <Stack.Item>
        <Button
          icon="circle"
          color={getEventIconColor(props.enabled, props.available)}
          tooltip={getEventIconToolTip(props.enabled, props.available)}
          onClick={() =>
            act('toggle_event', {
              name: props.name,
              ref: props.byondRef,
            })
          }
        />
      </Stack.Item>
      <Stack.Item>{props.name}</Stack.Item>
      <Stack.Item grow opacity={0.3} />
      <Stack.Item>
        <Button
          icon="gun"
          tooltip="Fire Event"
          color={props.customizable ? 'green' : 'blue'}
          onClick={() =>
            act('trigger_event', {
              name: props.name,
              ref: props.byondRef,
            })
          }
        />
        <Button
          icon="calendar-plus"
          tooltip="Schedule"
          disabled={props.alwaysCustom}
          onClick={() =>
            act('schedule_event', {
              name: props.name,
              ref: props.byondRef,
            })
          }
        />
      </Stack.Item>
    </Stack>
  );
};

interface EventTypeData {
  name: string;
  enabled: BooleanLike;
  startTime: number;
  delayLow: number;
  delayHigh: number;
  nextEvent: number;
  eventList: Array<EventData>;
}

const EventCategory = (props: EventTypeData) => {
  const { act } = useBackend<EventControllerData>();
  return (
    <Section
      title={
        <Stack align="center">
          <Stack.Item>{capitalize(props.name)} Events</Stack.Item>
          <Stack.Item>
            <Button.Checkbox
              checked={props.enabled}
              tooltip="Toggle Event Enablement"
              onClick={() =>
                act('set_category_value', {
                  name: 'toggle_category',
                  category: props.name,
                  new_data: !props.enabled,
                })
              }
            />
          </Stack.Item>
        </Stack>
      }
    >
      {props.startTime ? (
        <Flex>
          <Flex.Item mb={1}>
            <Stack>
              <Stack.Item>
                Next Time:
                <NumberInput
                  value={getMinutes(props.nextEvent)}
                  minValue={0}
                  maxValue={500}
                  stepPixelSize={4}
                  step={0.1}
                  width="50px"
                  format={(value) => toFixed(value, numberOfDecimalDigits(0.1))}
                  unit="Min"
                  onDrag={(value) =>
                    act('set_category_value', {
                      name: 'nextEvent',
                      category: props.name,
                      new_data: toMinutes(value),
                    })
                  }
                />
              </Stack.Item>
              <Stack.Item>
                Start Time:
                <NumberInput
                  value={getMinutes(props.startTime)}
                  minValue={0}
                  maxValue={500}
                  stepPixelSize={4}
                  step={0.1}
                  width="50px"
                  format={(value) => toFixed(value, numberOfDecimalDigits(0.1))}
                  unit="Min"
                  onDrag={(value) =>
                    act('set_category_value', {
                      name: 'startTime',
                      category: props.name,
                      new_data: toMinutes(value),
                    })
                  }
                />
              </Stack.Item>
              <Stack.Item>
                Time Between Events:
                <NumberInput
                  value={getMinutes(props.delayLow)}
                  minValue={0}
                  maxValue={500}
                  stepPixelSize={4}
                  step={0.1}
                  width="50px"
                  format={(value) => toFixed(value, numberOfDecimalDigits(0.1))}
                  unit="Min"
                  onDrag={(value) =>
                    act('set_category_value', {
                      name: 'delayLow',
                      category: props.name,
                      new_data: toMinutes(value),
                    })
                  }
                />
                /
                <NumberInput
                  value={getMinutes(props.delayHigh)}
                  minValue={0}
                  maxValue={500}
                  stepPixelSize={4}
                  step={0.1}
                  width="50px"
                  format={(value) => toFixed(value, numberOfDecimalDigits(0.1))}
                  unit="Min"
                  onDrag={(value) =>
                    act('set_category_value', {
                      name: 'delayHigh',
                      category: props.name,
                      new_data: toMinutes(value),
                    })
                  }
                />
              </Stack.Item>
            </Stack>
          </Flex.Item>
        </Flex>
      ) : (
        ''
      )}
      {/* TODO: consider not rendering if no contents? */}
      <Flex direction="column">
        {props.eventList ? (
          props.eventList.map((event) => (
            <Flex.Item key={event.name}>
              <Event {...event} />
            </Flex.Item>
          ))
        ) : (
          <Flex.Item />
        )}
      </Flex>
    </Section>
  );
};

interface EventControllerData {
  eventsEnabled: BooleanLike;
  announce: BooleanLike;
  timeLock: BooleanLike;

  minPopulation: number;
  aliveAntagonistThreshold: number;
  deadPlayersThreshold: number;
  eventData: Array<EventTypeData>;
  queuedEvents: Array<QueuedEventData>;
  roundStart: Array<RoundStartData>;
  storyTeller: StorytellerData;
  storyTellerList: Array<StorytellerData>;
}

export const EventController = () => {
  const { act, data } = useBackend<EventControllerData>();
  const [groupName, setGroupName] = useState('major');
  return (
    <Window width={600} height={600} title="Event Controller">
      <Window.Content scrollable>
        <Section
          title={
            <Stack align="center">
              <Stack.Item>
                <Button.Checkbox
                  checked={data.eventsEnabled}
                  tooltip="Toggle Event Enablement"
                  onClick={() =>
                    act('set_value', {
                      name: 'eventsEnabled',
                      new_data: !data.eventsEnabled,
                    })
                  }
                >
                  Events Enabled
                </Button.Checkbox>
              </Stack.Item>
              <Stack.Item>
                <Button.Checkbox
                  checked={data.announce}
                  tooltip="Toggle Event Announcements"
                  onClick={() =>
                    act('set_value', {
                      name: 'announce',
                      new_data: !data.announce,
                    })
                  }
                >
                  Announce Events
                </Button.Checkbox>
              </Stack.Item>
              <Stack.Item>
                <Button.Checkbox
                  checked={data.timeLock}
                  tooltip="Toggle Time Lock"
                  onClick={() =>
                    act('set_value', {
                      name: 'timeLock',
                      new_data: !data.timeLock,
                    })
                  }
                >
                  Time Locking
                </Button.Checkbox>
              </Stack.Item>
            </Stack>
          }
        >
          <Flex direction="column">
            <Flex.Item mb={1}>
              <Stack>
                <Stack.Item>
                  Minimum Population:
                  <NumberInput
                    value={data.minPopulation}
                    minValue={0}
                    maxValue={100}
                    stepPixelSize={4}
                    step={1}
                    width="30px"
                    onDrag={(value) =>
                      act('set_value', {
                        name: 'minPopulation',
                        new_data: value,
                      })
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  Alive Antagonist Threshold:
                  <NumberInput
                    value={data.aliveAntagonistThreshold}
                    minValue={0}
                    maxValue={1}
                    stepPixelSize={4}
                    step={0.01}
                    width="40px"
                    onDrag={(value) =>
                      act('set_value', {
                        name: 'aliveAntagonistThreshold',
                        new_data: value,
                      })
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  Dead Player Threshold:
                  <NumberInput
                    value={data.deadPlayersThreshold}
                    minValue={0}
                    maxValue={1}
                    stepPixelSize={4}
                    step={0.01}
                    width="40px"
                    onDrag={(value) =>
                      act('set_value', {
                        name: 'deadPlayersThreshold',
                        new_data: value,
                      })
                    }
                  />
                </Stack.Item>
              </Stack>
            </Flex.Item>
            <Flex.Item mb={1}>
              <Stack>
                <Stack.Item>
                  <Button
                    fontSize={1.5}
                    icon="book"
                    tooltip="Pick new Storyteller"
                    onClick={() => act('storyteller')}
                  >
                    Storyteller
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item label="Name">
                      {data.storyTeller.name}
                    </LabeledList.Item>
                    <LabeledList.Item label="Description">
                      {data.storyTeller.description}
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
            </Flex.Item>
          </Flex>
        </Section>

        <RoundStartSection roundStartData={data.roundStart} />

        <QueuedSection queueData={data.queuedEvents} />

        <Tabs>
          {data.eventData.map((eventCat) => (
            <Tabs.Tab
              key={eventCat.name}
              color="white"
              selected={eventCat.name === groupName}
              onClick={() => setGroupName(eventCat.name)}
            >
              {capitalize(eventCat.name)}
            </Tabs.Tab>
          ))}
        </Tabs>

        <Flex>
          {data.eventData
            .filter((eventCat) => eventCat.name === groupName)
            .map((eventCat) => (
              <Flex.Item mb={1} key={eventCat.name}>
                <EventCategory {...eventCat} />
              </Flex.Item>
            ))}
        </Flex>
      </Window.Content>
    </Window>
  );
};
