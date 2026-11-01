/**
 * @file
 * @copyright 2023
 * @author Garash2k (https://github.com/garash2k)
 * @license ISC
 */

import { useCallback } from 'react';
import { Button, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { PeripheralData, TerminalData } from './types';

interface PeripheralsSectionProps {
  peripherals: PeripheralData[];
}

export const PeripheralsSection = (props: PeripheralsSectionProps) => {
  const { act } = useBackend<TerminalData>();
  const { peripherals } = props;

  const handlePeripheralClick = useCallback(
    (peripheral: PeripheralData) =>
      act('buttonPressed', { card: peripheral.card, index: peripheral.index }),
    [act],
  );

  return (
    <Section fitted>
      {peripherals.map((peripheral) => {
        return (
          <Button
            key={peripheral.card}
            icon={peripheral.icon}
            fontFamily={peripheral.Clown ? 'Comic Sans MS' : 'Consolas'}
            color={peripheral.color ? 'green' : 'grey'}
            onClick={() => handlePeripheralClick(peripheral)}
          >
            {peripheral.label}
          </Button>
        );
      })}
    </Section>
  );
};
