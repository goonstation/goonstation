/**
 * @file
 * @copyright 2023
 * @author Garash2k (https://github.com/garash2k)
 * @license ISC
 */

import { useBackend } from '../../backend';
import { TerminalData } from './types';
import { Button, Section } from '../../components';

export const PheripheralsSection = (_props, context) => {
  const { act, data } = useBackend<TerminalData>(context);
  const peripherals = data.peripherals || [];

  const handlePheripheralClick = (peripheral) => act('buttonPressed', { card: peripheral.card, index: peripheral.index });

  return (
    <Section fitted>
      {peripherals.map(peripheral => {
        return (
          <Button
            key={peripheral.card}
            icon={peripheral.icon}
            content={peripheral.label}
            fontFamily={peripheral.Clown ? "Comic Sans MS" : "Consolas"}
            color={peripheral.color ? "green" : "grey"}
            onClick={() => handlePheripheralClick(peripheral)}
          />
        );
      })}
    </Section>
  );
};
