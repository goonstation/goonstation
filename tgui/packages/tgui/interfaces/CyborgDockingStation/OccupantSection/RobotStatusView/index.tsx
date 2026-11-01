/**
 * @file
 * @copyright 2022
 * @author glowbold (https://github.com/pgmzeta)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Box, LabeledList } from 'tgui-core/components';

import { DockingAllowedButton } from '../../DockingAllowedButton';
import type { OccupantDataRobot } from '../../type';
import { OccupantCellDisplay } from '../OccupantCellDisplay';
import { ClothingReportSection } from './ClothingReportSection';
import { DamageReportSection } from './DamageReportSection';
import { DecorationReportSection } from './DecorationReportSection';
import { UpgradeReportSection } from './UpgradeReportSection';

interface RobotStatusViewProps {
  act: (action: string, payload?: object) => void;
  cabling: number;
  fuel: number;
  occupant: OccupantDataRobot;
}

export const RobotStatusView = (props: RobotStatusViewProps) => {
  const { cabling, fuel, occupant, act } = props;
  const { cell, moduleName, upgrades, upgrades_max, parts } = occupant;
  const handleRemoveCell = () => act('cell-remove');
  const handleRemoveModule = () => act('module-remove');
  const handleRemoveUpgrade = (upgradeRef: string) =>
    act('upgrade-remove', { upgradeRef });
  const handleRepairStructure = () => act('repair-fuel');
  const handleRepairWiring = () => act('repair-wiring');
  const handleRemoveClothing = (clothingRef: string) =>
    act('clothing-remove', { clothingRef });
  const handleChangeCosmetic = {
    head: () => act('cosmetic-change-head'),
    chest: () => act('cosmetic-change-chest'),
    arms: () => act('cosmetic-change-arms'),
    legs: () => act('cosmetic-change-legs'),
    eyeGlow: () => act('occupant-fx'),
  };
  const handleChangePaintCosmetic = {
    add: () => act('occupant-paint-add'),
    change: () => act('occupant-paint-change'),
    remove: () => act('occupant-paint-remove'),
  };
  const hasModule = !!moduleName;
  return (
    <>
      <LabeledList>
        <OccupantCellDisplay cell={cell} onRemoveCell={handleRemoveCell} />
        <LabeledList.Item
          label="Module"
          buttons={
            <DockingAllowedButton
              onClick={handleRemoveModule}
              icon="minus"
              tooltip="Remove the occupant's module"
              disabled={!hasModule}
            />
          }
        >
          {moduleName || (
            <Box as="span" color="red">
              No Module Installed
            </Box>
          )}
        </LabeledList.Item>
      </LabeledList>
      <DamageReportSection
        parts={parts}
        fuel={fuel}
        cabling={cabling}
        onRepairStructure={handleRepairStructure}
        onRepairWiring={handleRepairWiring}
      />
      <UpgradeReportSection
        onRemoveUpgrade={handleRemoveUpgrade}
        upgrades={upgrades}
        upgrades_max={upgrades_max}
      />
      <DecorationReportSection
        cosmetics={occupant.cosmetics}
        onChangeCosmetic={handleChangeCosmetic}
        onChangePaintCosmetic={handleChangePaintCosmetic}
      />
      <ClothingReportSection
        clothes={occupant.clothing}
        onRemoveClothing={handleRemoveClothing}
      />
    </>
  );
};
