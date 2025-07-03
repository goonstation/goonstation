/**
 * @file
 * @copyright 2022
 * @author glowbold (https://github.com/pgmzeta)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Section, Stack } from 'tgui-core/components';

import { DockingAllowedButton } from '../../DockingAllowedButton';
import type { UpgradeData } from '../../type';

interface UpgradeReportSectionProps {
  onRemoveUpgrade: (upgradeRef: string) => void;
  upgrades: UpgradeData[];
  upgrades_max: number;
}

export const UpgradeReportSection = (props: UpgradeReportSectionProps) => {
  const { onRemoveUpgrade, upgrades, upgrades_max } = props;
  const upgradeCount = `Upgrades (${upgrades.length} / ${upgrades_max} installed)`;
  return (
    <Section title={upgradeCount}>
      {upgrades.map((upgrade) => (
        <Stack key={upgrade.ref}>
          <Stack.Item>{upgrade.name}</Stack.Item>
          <Stack.Item>
            <DockingAllowedButton
              compact
              icon="minus-circle"
              color="transparent"
              tooltip={`Remove ${upgrade.name}`}
              onClick={() => onRemoveUpgrade(upgrade.ref)}
            />
          </Stack.Item>
        </Stack>
      ))}
    </Section>
  );
};
