/**
 * @file
 * @copyright 2022
 * @author glowbold (https://github.com/pgmzeta)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Box, Section } from 'tgui-core/components';

import { DockingAllowedButton } from '../../DockingAllowedButton';
import type { ClothingData } from '../../type';

interface ClothingReportSectionProps {
  onRemoveClothing: (ref: string) => void;
  clothes: ClothingData[];
}

export const ClothingReportSection = (props: ClothingReportSectionProps) => {
  const { clothes, onRemoveClothing } = props;
  return (
    <Section title="Clothing">
      {clothes.length > 0 ? (
        clothes.map((cloth) => {
          return (
            <Box key={cloth.ref}>
              {cloth.name}
              <DockingAllowedButton
                onClick={() => onRemoveClothing(cloth.ref)}
                icon="minus-circle"
                color="transparent"
                tooltip="Remove from occupant"
              />
            </Box>
          );
        })
      ) : (
        <Box>No Clothing</Box>
      )}
    </Section>
  );
};
