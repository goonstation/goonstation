/**
 * @file
 * @copyright 2024
 * @author Original Azrun (https://github.com/Azrun)
 * @license ISC
 */

import { Box, Button, Icon, LabeledList, Section } from 'tgui-core/components';

import type { LongRangeData } from './types';

interface LongRangeSectionProps {
  isConnected: boolean;
  destinations: LongRangeData[];
  onSend: (name: string) => void;
  onReceive: (name: string) => void;
  onToggle: (name: string) => void;
}

export const LongRangeSection = (props: LongRangeSectionProps) => {
  const { isConnected, destinations, onSend, onReceive, onToggle } = props;

  return (
    <Section title="Destinations">
      <LabeledList>
        {destinations && destinations.length ? (
          destinations.map(({ name }) => (
            <LabeledList.Item key={name} label={name}>
              <Box textAlign="right">
                <Button
                  icon="sign-out-alt"
                  onClick={() => onSend(name)}
                  disabled={!isConnected}
                >
                  Send
                </Button>
                <Button
                  icon="sign-in-alt"
                  onClick={() => onReceive(name)}
                  disabled={!isConnected}
                >
                  Receive
                </Button>
                <Button onClick={() => onToggle(name)} disabled={!isConnected}>
                  <Icon name="ring" rotation={90} />
                  Toggle Portal
                </Button>
              </Box>
            </LabeledList.Item>
          ))
        ) : (
          <LabeledList.Item>
            No destinations are currently available.
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};
