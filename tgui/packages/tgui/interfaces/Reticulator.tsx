/**
 * @file
 * @copyright 2025
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @license ISC
 */

import { useState } from 'react';
import {
  Button,
  Flex,
  LabeledList,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface ReticulatorData {
  essenceShards;
  powerShards;
  spacetimeShards;
  fusionShards;
  omniShards;
  storedArtifact;
  storedItem;
  canBreakdownArtifact;
  canBreakdownFusion;
  canCreateResonator;
  canCreateTuner;
  canCreateArtifact;
  canCombineArtifacts;
  canImbueLight;
  canBreakdownForMats;
  canModifyMaterial;
  canUpgradeStorage;
  canIncreaseReagents;
  canIncreaseCellCapacity;
  canUpgradeMiningPower;
  breakdownTip;
  breakdownFusionTip;
  resonatorTip;
  tunerTip;
  createArtTip;
  combineArtsTip;
  imbueLightTip;
  breakdownMatsTip;
  modifyMaterialTip;
  upgradeStorageTip;
  increaseReagentsTip;
  increaseCellCapTip;
  upgradeMiningPowerTip;
  reticulatedArtifacts;
}

export const Reticulator = () => {
  const { act, data } = useBackend<ReticulatorData>();
  const {
    essenceShards,
    powerShards,
    spacetimeShards,
    fusionShards,
    omniShards,
    storedArtifact,
    storedItem,
    canBreakdownArtifact,
    canBreakdownFusion,
    canCreateResonator,
    canCreateTuner,
    canCreateArtifact,
    canCombineArtifacts,
    canImbueLight,
    canBreakdownForMats,
    canModifyMaterial,
    canUpgradeStorage,
    canIncreaseReagents,
    canIncreaseCellCapacity,
    canUpgradeMiningPower,
    breakdownTip,
    breakdownFusionTip,
    resonatorTip,
    tunerTip,
    createArtTip,
    combineArtsTip,
    imbueLightTip,
    breakdownMatsTip,
    modifyMaterialTip,
    upgradeStorageTip,
    increaseReagentsTip,
    increaseCellCapTip,
    upgradeMiningPowerTip,
    reticulatedArtifacts,
  } = data;
  const [tabIndex, setTabIndex] = useState(1);
  return (
    <Window title="Reticulator" width={600} height={350}>
      <Window.Content>
        <Flex>
          <Flex.Item mr={1}>
            <Section title="Storage">
              <Section title="Shards">
                <LabeledList>
                  <LabeledList.Item label="Essence">
                    {essenceShards}
                  </LabeledList.Item>
                  <LabeledList.Item label="Power">
                    {powerShards}
                  </LabeledList.Item>
                  <LabeledList.Item label="Spacetime">
                    {spacetimeShards}
                  </LabeledList.Item>
                  <LabeledList.Item label="Fusion">
                    {fusionShards}
                  </LabeledList.Item>
                  <LabeledList.Item label="Omni">{omniShards}</LabeledList.Item>
                  <LabeledList.Item label="Database">
                    <Button selected onClick={() => act('view_database')}>
                      Info
                    </Button>
                  </LabeledList.Item>
                </LabeledList>
              </Section>
              <Section title="Objects">
                <LabeledList>
                  <LabeledList.Item
                    label="Artifact"
                    buttons={
                      <Button
                        disabled={!storedArtifact}
                        selected={!!storedArtifact}
                        onClick={() => act('eject_art')}
                      >
                        Eject
                      </Button>
                    }
                  >
                    {storedArtifact || 'None'}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Other"
                    buttons={
                      <Button
                        disabled={!storedItem}
                        selected={!!storedItem}
                        onClick={() => act('eject_item')}
                      >
                        Eject
                      </Button>
                    }
                  >
                    {storedItem || 'None'}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Section>
          </Flex.Item>
          <Flex.Item mr={1}>
            <Section title="Interface">
              <Tabs>
                <Tabs.Tab
                  selected={tabIndex === 1}
                  onClick={() => setTabIndex(1)}
                >
                  Breakdown
                </Tabs.Tab>
                <Tabs.Tab
                  selected={tabIndex === 2}
                  onClick={() => setTabIndex(2)}
                >
                  Create
                </Tabs.Tab>
                <Tabs.Tab
                  selected={tabIndex === 3}
                  onClick={() => setTabIndex(3)}
                >
                  Modify
                </Tabs.Tab>
              </Tabs>
              {tabIndex === 1 && (
                <Section>
                  <Flex direction="column" wrap="wrap">
                    <Flex.Item>
                      <Button
                        disabled={!canBreakdownArtifact}
                        selected={canBreakdownArtifact}
                        onClick={() => act('breakdown_artifact')}
                        tooltip={breakdownTip}
                      >
                        Breakdown regular
                      </Button>
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        disabled={!canBreakdownFusion}
                        selected={canBreakdownFusion}
                        onClick={() => act('breakdown_fusion')}
                        tooltip={breakdownFusionTip}
                      >
                        Breakdown for Fusion shard
                      </Button>
                    </Flex.Item>
                  </Flex>
                </Section>
              )}
              {tabIndex === 2 && (
                <Section>
                  <Flex direction="column" wrap="wrap">
                    <Flex.Item>
                      <Button
                        disabled={!canCreateResonator}
                        selected={canCreateResonator}
                        onClick={() => act('create_resonator')}
                        tooltip={resonatorTip}
                      >
                        Resonator
                      </Button>
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        disabled={!canCreateTuner}
                        selected={canCreateTuner}
                        onClick={() => act('create_tuner')}
                        tooltip={tunerTip}
                      >
                        Tuner
                      </Button>
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        disabled={!canCreateArtifact}
                        selected={canCreateArtifact}
                        onClick={() => act('create_artifact')}
                        tooltip={createArtTip}
                      >
                        Researched Artifact
                      </Button>
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        disabled={!canCombineArtifacts}
                        selected={canCombineArtifacts}
                        onClick={() => act('combine_artifacts')}
                        tooltip={combineArtsTip}
                      >
                        Combine Artifacts
                      </Button>
                    </Flex.Item>
                  </Flex>
                </Section>
              )}
              {tabIndex === 3 && (
                <Section>
                  <Flex direction="column" wrap="wrap">
                    <Flex.Item>
                      <Button
                        disabled={!canImbueLight}
                        selected={canImbueLight}
                        onClick={() => act('imbue_light')}
                        tooltip={imbueLightTip}
                      >
                        Imbue Light
                      </Button>
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        disabled={!canBreakdownForMats}
                        selected={canBreakdownForMats}
                        onClick={() => act('breakdown_mats')}
                        tooltip={breakdownMatsTip}
                      >
                        Material Breakdown
                      </Button>
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        disabled={!canModifyMaterial}
                        selected={canModifyMaterial}
                        onClick={() => act('modify_material')}
                        tooltip={modifyMaterialTip}
                      >
                        Material Modification
                      </Button>
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        disabled={!canUpgradeStorage}
                        selected={canUpgradeStorage}
                        onClick={() => act('upgrade_storage')}
                        tooltip={upgradeStorageTip}
                      >
                        Storage Upgrade
                      </Button>
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        disabled={!canIncreaseReagents}
                        selected={canIncreaseReagents}
                        onClick={() => act('increase_reagents')}
                        tooltip={increaseReagentsTip}
                      >
                        Reagent Capacity
                      </Button>
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        disabled={!canIncreaseCellCapacity}
                        selected={canIncreaseCellCapacity}
                        onClick={() => act('increase_cell_capacity')}
                        tooltip={increaseCellCapTip}
                      >
                        Cell Capacity
                      </Button>
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        disabled={!canUpgradeMiningPower}
                        selected={canUpgradeMiningPower}
                        onClick={() => act('upgrade_mining_power')}
                        tooltip={upgradeMiningPowerTip}
                      >
                        Mining Power
                      </Button>
                    </Flex.Item>
                  </Flex>
                </Section>
              )}
            </Section>
          </Flex.Item>
          <Flex.Item>
            <Section title="Reticulated Artifacts" scrollable fill>
              <Stack vertical fill>
                {reticulatedArtifacts.map((item, index) => (
                  <Stack.Item key={index}>{item}</Stack.Item>
                ))}
              </Stack>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
