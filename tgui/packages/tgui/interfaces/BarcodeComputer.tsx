/**
 * @file
 * @copyright 2022
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @license MIT
 */

import { useState } from 'react';
import { Box, Button, NumberInput, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const BarcodeComputerSection = (props) => {
  const { title, destinations, act, amount } = props;
  return (
    <Section title={title}>
      {destinations.map((destination) => {
        const { crate_tag, name } = destination;
        return (
          <Button
            width="100%"
            align="center"
            key={crate_tag}
            onClick={() => act('print', { crate_tag, amount })}
          >
            {name || crate_tag}
          </Button>
        );
      })}
    </Section>
  );
};

const IDCard = (props) => {
  if (!props.card) {
    return;
  }
  const { card, act } = props;
  return (
    <Button
      icon="eject"
      tooltip="Clear scanned card"
      tooltipPosition="bottom-end"
      onClick={() => {
        act('reset_id');
      }}
    >
      {`${card.name} (${card.role})`}
    </Button>
  );
};

interface BarcodeComputerData {
  sections;
  card;
}

export const BarcodeComputer = () => {
  const { act, data } = useBackend<BarcodeComputerData>();
  const { sections, card } = data;
  const [amount, setAmount] = useState(1);
  return (
    <Window title="Barcode computer" width={600} height={450}>
      <Window.Content scrollable>
        <Stack>
          <Stack.Item grow={1}>
            <Section title="Amount to print" fill>
              <Box align="center">
                <NumberInput
                  value={amount}
                  minValue={1}
                  maxValue={5}
                  step={1}
                  stepPixelSize={15}
                  unit={'Barcodes'}
                  onDrag={(value) => setAmount(value)}
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
          {sections.map((section) => {
            const { title, destinations } = section;
            return (
              <Stack.Item key={title} width="33%">
                <BarcodeComputerSection
                  title={title}
                  destinations={destinations}
                  act={act}
                  amount={amount}
                />
              </Stack.Item>
            );
          })}
        </Stack>
      </Window.Content>
    </Window>
  );
};
