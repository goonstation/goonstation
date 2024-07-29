/**
 * @file
 * @copyright 2023
 * @author Garash2k (https://github.com/garash2k)
 * @license ISC
 */

import { Button, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { TerminalData } from './types';

export const PheripheralsSection = () => {
  const { act, data } = useBackend<TerminalData>();
  const peripherals = data.peripherals || [];

  const handlePheripheralClick = (peripheral) =>
    act('buttonPressed', { card: peripheral.card, index: peripheral.index });

  return (
    <Section fitted>
      {peripherals.map((peripheral) => {
        return (
          <Button
            key={peripheral.card}
            icon={peripheral.icon}
            fontFamily={peripheral.Clown ? 'Comic Sans MS' : 'Consolas'}
            color={peripheral.color ? 'green' : 'grey'}
            onClick={() => handlePheripheralClick(peripheral)}
          >
            {peripheral.label}
          </Button>
        );
      })}
    </Section>
  );
};
