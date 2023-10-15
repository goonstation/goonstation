import { Box, Button, LabeledList, Section } from '../../components';

interface ConnectionSectionProps {
  isConnected: boolean;
  onReset: () => void;
  onRetry: () => void;
}

export const ConnectionSection = (props: ConnectionSectionProps) => {
  const { isConnected, onReset, onRetry } = props;
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
          {isConnected ? <Box color="green">Connected</Box> : <Box color="red">No connection to host</Box>}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
