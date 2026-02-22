/**
 * @file
 * @copyright 2022
 * @author glowbold (https://github.com/pgmzeta)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Box, LabeledList, Section } from 'tgui-core/components';

import { CellChargeBar } from '../CellChargeBar';
import { DockingAllowedButton } from '../DockingAllowedButton';
import type { PowerCellData } from '../type';

interface AvailableCellsSectionProps {
  items: PowerCellData[];
  onEject: (ref: string) => void;
  onInstall: (ref: string) => void;
}

export const AvailableCellsSection = (props: AvailableCellsSectionProps) => {
  const { items, onEject, onInstall } = props;
  return (
    <Section title="Power Cells">
      {items.length > 0 ? (
        <LabeledList>
          {items.map((item) => {
            return (
              <div key={item.ref}>
                <LabeledList.Item
                  label={item.name}
                  buttons={
                    <>
                      <DockingAllowedButton
                        onClick={() => onInstall(item.ref)}
                        icon="plus"
                        tooltip="Add to occupant"
                      />
                      <DockingAllowedButton
                        onClick={() => onEject(item.ref)}
                        icon="eject"
                        tooltip="Eject from station"
                      />
                    </>
                  }
                >
                  <CellChargeBar cell={item} />
                </LabeledList.Item>
              </div>
            );
          })}
        </LabeledList>
      ) : (
        <Box as="div">None Stored</Box>
      )}
    </Section>
  );
};
