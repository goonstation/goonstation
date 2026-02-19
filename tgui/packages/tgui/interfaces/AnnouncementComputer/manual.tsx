/**
 * @file
 * @copyright 2024
 * @author Valtsu0 (https://github.com/Valtsu0)
 * @license ISC
 */

import {
  AnimatedNumber,
  Button,
  Input,
  Section,
  Stack,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend, useSharedState } from '../../backend';
import { formatTime } from '../../format';
import { AnnouncementCompData } from './type';

type Status = {
  canTransmit: BooleanLike;
  text: string;
  color: string;
};

export const ManualAnnouncement = (_props) => {
  const { act, data } = useBackend<AnnouncementCompData>();
  const { card_name, status_message, time, max_length } = data;

  const [input, setInput] = useSharedState('input', '');
  const [oldInput, setOldInput] = useSharedState('oldInput', '');

  let status: Status = getStatus(input, max_length, status_message, time);

  const handleBlur = () => {
    if (input === oldInput) {
      return;
    }
    act('log', { value: input, old: oldInput });
    setOldInput(input);
  };

  const onTransmit = () => {
    act('transmit', { value: input });
    setInput('');
    setOldInput('');
  };

  const handleType = (value: string) => {
    setInput(value);
    status = getStatus(input, max_length, status_message, time); // TODO: status should not be changed like this
  };

  return (
    <Section title="Make an Announcement">
      <Stack vertical>
        <Stack.Item color={status['color']}>
          Status: {status['text']}
        </Stack.Item>
        <Stack.Item>
          <Button onClick={() => act('id')} icon="eject" preserveWhitespace>
            {card_name || 'Insert card'}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <AnimatedNumber value={time} format={formatTime} />
        </Stack.Item>
        <Stack.Item>
          <Input
            autoFocus
            fluid
            onChange={handleType}
            onBlur={handleBlur}
            placeholder="Type something..."
            value={input}
          />
        </Stack.Item>
        <Stack.Item fontSize="16px">
          <Button
            icon="bullhorn"
            fluid
            disabled={!status['canTransmit']}
            onClick={() => onTransmit()}
          >
            Transmit
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const getStatus = (input, max_length, status, time) => {
  if (time > 0) {
    return {
      canTransmit: false,
      text: 'Broadcast delay in effect.',
      color: 'bad',
    };
  } else if (status === 'Insert Card') {
    return { canTransmit: false, text: 'Insert Card', color: 'average' };
  } else if (status) {
    return { canTransmit: false, text: status, color: 'bad' };
  } else if (!!max_length && input.length > max_length) {
    return {
      canTransmit: false,
      text: `Message too long, maximium is ${max_length} characters.`,
      color: 'average',
    };
  } else if (!input) {
    return { canTransmit: false, text: 'Input message.', color: 'average' };
  }
  return { canTransmit: true, text: 'Ready to transmit!', color: 'good' };
};
