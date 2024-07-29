/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Box, Button, LabeledList, Section } from 'tgui-core/components';

interface ConnectionSectionProps {
  isConnected: boolean;
  isPanelOpen?: boolean;
  onCyclePad: () => void;
  onReset: () => void;
  onRetry: () => void;
  padNum: number;
}

export const ConnectionSection = (props: ConnectionSectionProps) => {
  const { isConnected, isPanelOpen, onCyclePad, onReset, onRetry, padNum } =
    props;
  const connectionButtons = isConnected ? (
    <Button icon="power-off" color="red" onClick={onReset}>
      Reset
    </Button>
  ) : (
    <Button icon="power-off" color="green" onClick={onRetry}>
      Retry
    </Button>
  );
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Connection" buttons={connectionButtons}>
          {isConnected ? (
            <Box color="green">Connected</Box>
          ) : (
            <Box color="red">No connection to host</Box>
          )}
        </LabeledList.Item>
        {isPanelOpen && (
          <LabeledList.Item
            label="Linked Pad"
            buttons={
              <Button icon="arrows-spin" onClick={onCyclePad}>
                Cycle
              </Button>
            }
          >
            {padNum}
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};
