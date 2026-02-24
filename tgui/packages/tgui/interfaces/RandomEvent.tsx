/**
 * Copyright (c) 2022 @Azrun
 * SPDX-License-Identifier: MIT
 */

import { Box, Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { DataInputOptions } from './common/DataInput';

interface RandomEventData {
  eventName;
  eventOptions;
}

export const RandomEvent = () => {
  const { act, data } = useBackend<RandomEventData>();
  const { eventName, eventOptions } = data;

  return (
    <Window title="Random Event" width={700} height={600}>
      <Window.Content scrollable>
        <Section title={eventName}>
          <DataInputOptions options={eventOptions} />
          <Box m={1}>
            <Button fluid onClick={() => act('activate')}>
              Confirm Event
            </Button>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
