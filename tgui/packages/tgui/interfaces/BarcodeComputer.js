import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, Section, Flex, Box, Stack } from '../components';
import { Window } from '../layouts';

const BarcodeComputerSection = (props, context) => {
  const {
    title,
    destinations,
    act,
  } = props;
  return (
    <Section title={title}>
      {destinations.map(destination => {
        const {
          crate_tag,
          name,
          icon,
        } = destination;
        return (
          <Button
            key={crate_tag}
            content={name ? name : crate_tag}
            onClick={() => act('print', { crate_tag })}
          />
        );
      })}
    </Section>
  );
};

const IDCard = (props, context) => {
  if (!props.card) {
    return;
  }
  const {
    card: {
      name,
      role,
      icon,
    },
  } = props;
  return (
    <Stack align="center">
      <img
        src={icon}
        style={{
          'width': '64px',
          'height': '64px',
          '-ms-interpolation-mode': 'nearest-neighbor',
        }}
      />
      <Box align="left">
        {name}
        <br />
        {role}
      </Box>
    </Stack>
  );
};

export const BarcodeComputer = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    amount,
    sections,
    card,
  } = data;
  return (
    <Window
      title="Barcode computer"
      width={500}
      height={500}
    >
      <Window.Content scrollable>
        <Stack>
          <Stack.Item grow={1}>
            <Section title="Amount to print" fill>
              <Box align="center">
                <NumberInput
                  value={amount}
                  minValue={1} maxValue={5}
                  stepPixelSize={15}
                  unit="Barcodes"
                  onChange={(e, value) => act('set_amount', { value })}
                />
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Section title="Scanned ID card">
              <Box align="center">
                <Button onClick={() => { act("reset_id"); }} color="grey">
                  <IDCard align="right" card={card} />
                </Button>
              </Box>
            </Section>
          </Stack.Item>
        </Stack>
        <br />
        <Stack vertical>
          {sections.map(section => {
            const {
              title,
              destinations,
            } = section;
            return (
              <Stack.Item key={title}>
                <BarcodeComputerSection
                  title={title}
                  destinations={destinations}
                  act={act} />
              </Stack.Item>
            );
          })}
        </Stack>
      </Window.Content>
    </Window>
  );
};
