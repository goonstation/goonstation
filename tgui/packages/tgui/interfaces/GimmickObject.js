/**
 * Copyright (c) 2022 @Azrun
 * SPDX-License-Identifier: MIT
 */

import { useBackend } from '../backend';
import { Box, Button, Flex, NumberInput, LabeledList, Input, Section, Tooltip } from '../components';
import { Window } from '../layouts';

export const GimmickObject = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    eventList,
    interactiveTypes,
    activeStage,
    icon,
    iconState,
  } = data;

  return (
    <Window
      title="Gimmick Object Editor"
      width={675}
      height={600}>
      <Window.Content scrollable>
        <Section
          title={
            <Box
              inline>
              Edit Interactive Steps
            </Box>
          }>
          <Flex direction="column">
            {Object.keys(eventList).map((event, eventIndex) => (
              <Flex.Item key={eventIndex}>
                <Section title={eventIndex}>
                  <Flex.Item mb={1}>
                    <Tooltip content="Move Step Down">
                      <Button
                        icon="angle-down"
                        disabled={parseInt(event, 10) >= eventList.length - 1}
                        onClick={() => act('move-down', { event: eventIndex })} />
                    </Tooltip>

                    <Tooltip content="Move Step Down">

                      <Button
                        icon="angle-up"
                        disabled={parseInt(event, 10) <= 0}
                        onClick={() => act('move-up', { event: eventIndex })} />
                    </Tooltip>

                    <Tooltip content="Make Active Step">

                      <Button
                        icon="play"
                        // color=
                        disabled={parseInt(event, 10) === parseInt(activeStage, 10)-1}
                        onClick={() => act('active_step', { event: eventIndex })} />
                    </Tooltip>


                    <Tooltip content="Remove step from Gimmick">

                      <Button
                        icon="trash"
                        color="red"
                        onClick={() => act('delete_event', { event: eventIndex })}
                      />
                    </Tooltip>

                    <LabeledList>
                      <Tooltip content="Set Tool Interactive Flags (Blank will be AttackHand)">
                        <LabeledList.Item label="Interactive Flags" >
                          {Object.keys(interactiveTypes).map((type, interactiveIndex) => (
                            <Button
                              key={interactiveIndex}
                              selected={eventList[event].interaction & interactiveTypes[type]}
                              onClick={() => act('interaction', { event: eventIndex, value: interactiveTypes[type] })}>
                              {type}
                            </Button>
                          ))}
                        </LabeledList.Item>
                      </Tooltip>
                      <Tooltip content="Hint appended to examine text">
                        <LabeledList.Item label="Description">


                          <Input fluid
                            value={eventList[event].description}
                            onInput={(e, description) => act('description', { event: eventIndex, value: description })} />
                        </LabeledList.Item>
                      </Tooltip>

                      <Tooltip content="Actionbar Duration">
                        <LabeledList.Item label="Duration">

                          <NumberInput
                            animated
                            width="7em"
                            value={eventList[event].duration}
                            minValue={1}
                            maxValue={90000}
                            onChange={(e, targetDuration) => act('duration', { event: eventIndex, value: targetDuration })} />
                          Seconds
                        </LabeledList.Item>
                      </Tooltip>
                      <Tooltip content="Visible Text Appended after [src]">
                        <LabeledList.Item label="Visible Message">

                          <Input fluid
                            value={eventList[event].message}
                            onInput={(e, message) => act('message', { event: eventIndex, value: message })} />
                        </LabeledList.Item>
                      </Tooltip>
                    </LabeledList>
                    <Tooltip content="Notify in-game admins that action was performed">

                      <Button
                        icon="flag"
                        selected={eventList[event].notify}
                        onClick={() => act('notify', { event: eventIndex, value: !eventList[event].notify })}
                      >
                        Notify Admins
                      </Button>
                    </Tooltip>

                  </Flex.Item>
                </Section>
              </Flex.Item>
            ))}
          </Flex>
          <Box m={1}>
            <Button
              onClick={() => act('add_new')}
            >
              Add Event
            </Button>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
