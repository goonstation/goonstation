/**
 * @file
 * @copyright 2022
 * @author glowbold (https://github.com/pgmzeta)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Box, Section } from 'tgui-core/components';

import { DockingAllowedButton } from '../DockingAllowedButton';
import type { ItemData } from '../type';

interface StandardAvailableSectionProps<T extends ItemData> {
  items: T[];
  onEject: (ref: string) => void;
  onInstall: (ref: string) => void;
  title: string;
}

export const StandardAvailableSection = <T extends ItemData>(
  props: StandardAvailableSectionProps<T>,
) => {
  const { items, onEject, onInstall, title } = props;
  return (
    <Section title={title}>
      {items.length > 0 ? (
        items.map((item) => (
          <div key={item.ref}>
            {item.name}
            <DockingAllowedButton
              onClick={() => onInstall(item.ref)}
              icon="plus-circle"
              color="transparent"
              tooltip="Add to occupant"
            />
            <DockingAllowedButton
              onClick={() => onEject(item.ref)}
              icon="eject"
              color="transparent"
              tooltip="Eject from station"
            />
          </div>
        ))
      ) : (
        <Box as="div">None Stored</Box>
      )}
    </Section>
  );
};
