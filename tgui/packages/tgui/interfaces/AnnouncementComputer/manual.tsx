/**
 * @file
 * @copyright 2024
 * @author Valtsu0 (https://github.com/Valtsu0)
 * @license ISC
 */

import { useBackend } from '../../backend';
import { AnimatedNumber, Button, Input, Section, Stack } from '../../components';
import { formatTime } from '../../format';
import { AnnouncementCompData } from './data';

export const ManualAnnouncement = (_props, context) => {
  const { act, data } = useBackend<AnnouncementCompData>(context);
  // Extract `health` and `color` variables from the `data` object.
  const { message, card_name, status, status_message, time } = data;

  return (
    <Section title="Make an Announcement">
      <Stack vertical>
        <Stack.Item color={status}>
          Status: {status_message}
        </Stack.Item>
        <Stack.Item>
          <Button
            onClick={() => act("id")}
            icon="eject"
            preserveWhitespace>
            {card_name || "Insert card"}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <AnimatedNumber value={time} format={formatTime} />
        </Stack.Item>
        <Stack.Item>
          <Input
            autoFocus
            fluid
            onChange={(e, value) => act('message', { value })}
            placeholder="Type something..."
            value={message}
          />
        </Stack.Item>
        <Stack.Item label="Button" fontSize="16px">
          <Button
            icon="bullhorn"
            content="Transmit"
            fluid
            disabled={status !== "good"}
            onClick={() => act('transmit')} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};
