import { useBackend, useLocalState } from '../backend';
import { Button, NumberInput, Section, Box, Stack } from '../components';
import { Window } from '../layouts';

const BarcodeComputerSection = (props, context) => {
  const {
    title,
    destinations,
    act,
    amount,
  } = props;
  return (
    <Section title={title}>
      {destinations.map(destination => {
        const {
          crate_tag,
          name,
        } = destination;
        return (
          <Button
            width="100%"
            align="center"
            key={crate_tag}
            content={name ? name : crate_tag}
            onClick={() => act('print', { crate_tag, amount })}
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
    card,
    act,
  } = props;
  return (
    <Button
      icon="eject"
      content={card.name + ` (${card.role})`}
      tooltip="Clear scanned card"
      tooltipPosition="bottom-end"
      onClick={() => { act("reset_id"); }}
    />
  );
};

export const BarcodeComputer = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    sections,
    card,
  } = data;
  const [amount, setAmount] = useLocalState(context, 'amount', 1);
  return (
    <Window
      title="Barcode computer"
      width={600}
      height={450}
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
                  unit={"Barcodes"}
                  onDrag={(e, value) => setAmount(value)}
                />
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Section title="Scanned ID card" fill>
              <Box align="center">
                <IDCard card={card} act={act} />
                <br />
                {card ? `Account balance: ${card.balance}⪽` : null}
              </Box>
            </Section>
          </Stack.Item>
        </Stack>
        <br />
        <Stack>
          {sections.map(section => {
            const {
              title,
              destinations,
            } = section;
            return (
              <Stack.Item key={title} width="33%">
                <BarcodeComputerSection
                  title={title}
                  destinations={destinations}
                  act={act}
                  amount={amount} />
              </Stack.Item>
            );
          })}
        </Stack>
      </Window.Content>
    </Window>
  );
};
