/**
 * @file
 * @copyright 2022
 * @author glowbold (https://github.com/pgmzeta)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import type { CyborgDockingStationData } from '../type';
import { AvailableCellsSection } from './AvailableCellsSection';
import { StandardAvailableSection } from './StandardAvailableSection';

export const SuppliesSection = () => {
  const { act, data } = useBackend<CyborgDockingStationData>();
  const {
    allow_self_service,
    cabling,
    cells,
    clothes,
    fuel,
    modules,
    upgrades,
    viewer_is_robot,
  } = data;
  const handleToggleSelfService = () => act('self-service');
  const handleInstallModule = (moduleRef: string) =>
    act('module-install', { moduleRef });
  const handleEjectModule = (moduleRef: string) =>
    act('module-eject', { moduleRef });
  const handleInstallClothing = (clothingRef: string) =>
    act('clothing-install', { clothingRef });
  const handleEjectClothing = (clothingRef: string) =>
    act('clothing-eject', { clothingRef });
  const handleInstallUpgrade = (upgradeRef: string) =>
    act('upgrade-install', { upgradeRef });
  const handleEjectUpgrade = (upgradeRef: string) =>
    act('upgrade-eject', { upgradeRef });
  const handleInstallCell = (cellRef: string) =>
    act('cell-install', { cellRef });
  const handleEjectCell = (cellRef: string) => act('cell-eject', { cellRef });
  return (
    <Section title="Supplies">
      <LabeledList>
        <LabeledList.Item label="Welding Fuel">{fuel}</LabeledList.Item>
        <LabeledList.Item label="Wire Cabling">{cabling}</LabeledList.Item>
        <LabeledList.Item label="Self Service">
          <Button.Checkbox
            tooltip="Toggle self-service."
            checked={allow_self_service}
            disabled={viewer_is_robot}
            onClick={handleToggleSelfService}
          >
            {allow_self_service ? 'Enabled' : 'Disabled'}
          </Button.Checkbox>
        </LabeledList.Item>
      </LabeledList>
      <StandardAvailableSection
        items={modules}
        onInstall={handleInstallModule}
        onEject={handleEjectModule}
        title="Modules"
      />
      <StandardAvailableSection
        items={upgrades}
        onInstall={handleInstallUpgrade}
        onEject={handleEjectUpgrade}
        title="Upgrades"
      />
      <AvailableCellsSection
        items={cells}
        onInstall={handleInstallCell}
        onEject={handleEjectCell}
      />
      <StandardAvailableSection
        items={clothes}
        onInstall={handleInstallClothing}
        onEject={handleEjectClothing}
        title="Upgrades"
      />
    </Section>
  );
};
