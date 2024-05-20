/**
 * Copyright (c) 2022 @Azrun
 * SPDX-License-Identifier: MIT
 */

import { useBackend } from '../backend';
import { Box, Button, Flex, Section } from '../components';
import { DataInputOptions } from './common/DataInput';
import { Window } from '../layouts';

export const RandomEvent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    eventName,
    eventOptions,
  } = data;

  return (
    <Window
      title="Random Event"
      width={700}
      height={600}>
      <Window.Content scrollable>
        <Section title={eventName}>
          <Flex direction="row">
            <Flex.Item ml={1}>
              <DataInputOptions
                options={eventOptions}
              />
            </Flex.Item>
          </Flex>
          <Box m={1}>
            <Button
              fluid
              onClick={() => act("activate")}
            >
              Confirm Event
            </Button>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
