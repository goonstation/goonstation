/**
 * @file
 * @copyright 2024
 * @author Valtsu0 (https://github.com/Valtsu0)
 * @license ISC
 */

import { Input, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { AnnouncementCompData } from './type';

export interface AutomaticAnnouncementData {
  arrivalalert: string;
}

export const AutomaticAnnouncement = (_props: unknown) => {
  const { act, data } = useBackend<AnnouncementCompData>();
  const { arrivalalert } = data;

  return (
    <Section title="Arrival Announcement Message">
      <Stack vertical>
        <Stack.Item>
          Valid tokens: $NAME, $JOB, $STATION, $THEY, $THEM, $THEIR. Leave the
          field empty for no message.
        </Stack.Item>
        <Stack.Item>
          <Input
            fluid
            onChange={(value) => act('arrival_message', { value })}
            placeholder="Type something..."
            value={arrivalalert}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};
