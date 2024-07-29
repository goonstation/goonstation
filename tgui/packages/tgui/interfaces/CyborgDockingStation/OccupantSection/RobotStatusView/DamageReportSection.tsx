/**
 * @file
 * @copyright 2022
 * @author glowbold (https://github.com/pgmzeta)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Box, Flex, LabeledList, Section } from 'tgui-core/components';

import { COLORS } from '../../../../constants';
import { DockingAllowedButton } from '../../DockingAllowedButton';
import { isPresentPartsData, PartData, PartListData } from '../../type';

interface DamageReportSectionProps {
  cabling: number;
  fuel: number;
  onRepairStructure: () => void;
  onRepairWiring: () => void;
  parts: PartListData;
}

export const DamageReportSection = (props: DamageReportSectionProps) => {
  const { cabling, fuel, parts, onRepairStructure, onRepairWiring } = props;
  return (
    <Section
      title="Damage Report"
      buttons={
        <>
          <DockingAllowedButton
            disabled={fuel < 1}
            icon="wrench"
            backgroundColor={COLORS.damageType.brute}
            tooltip="Fix structural damage"
            onClick={onRepairStructure}
          />
          <DockingAllowedButton
            disabled={cabling < 1}
            icon="fire"
            backgroundColor={COLORS.damageType.burn}
            tooltip="Fix wiring damage"
            onClick={onRepairWiring}
          />
        </>
      }
    >
      <LabeledList>
        <PartDisplay label="Head" partData={parts.head} />
        <PartDisplay label="Chest" partData={parts.chest} />
        <PartDisplay label="Left Arm" partData={parts.arm_l} />
        <PartDisplay label="Right Arm" partData={parts.arm_r} />
        <PartDisplay label="Left Leg" partData={parts.leg_l} />
        <PartDisplay label="Right Leg" partData={parts.leg_r} />
      </LabeledList>
    </Section>
  );
};

interface PartDisplayProps {
  label: string;
  partData: PartData;
}

const PartDisplay = (props: PartDisplayProps) => {
  const { label, partData } = props;
  if (!isPresentPartsData(partData)) {
    return (
      <LabeledList.Item color="red" label={label}>
        <Box bold>MISSING!</Box>
      </LabeledList.Item>
    );
  }
  const partBluntPercent = Math.floor(
    (partData.dmg_blunt / partData.max_health) * 100,
  );
  const partBurnsPercent = Math.floor(
    (partData.dmg_burns / partData.max_health) * 100,
  );
  if (partBluntPercent || partBurnsPercent) {
    return (
      <LabeledList.Item label={label}>
        <Flex>
          <Flex.Item grow={1}>
            <Flex>
              <Flex.Item
                backgroundColor={COLORS.damageType.brute}
                width={partBluntPercent + '%'}
              />
              <Flex.Item
                backgroundColor={COLORS.damageType.burn}
                width={partBurnsPercent + '%'}
              />
              <Flex.Item grow={1} backgroundColor="#000000" stretch>
                &nbsp;
              </Flex.Item>
            </Flex>
          </Flex.Item>
          <Flex.Item shrink>
            <Flex>
              <Flex.Item
                shrink
                width="25px"
                backgroundColor="#330000"
                color={COLORS.damageType.brute}
                bold
              >
                <Box textAlign="center">
                  {partBluntPercent > 0 ? partBluntPercent : '--'}
                </Box>
              </Flex.Item>
              <Flex.Item
                shrink
                width="25px"
                backgroundColor={'#331100'}
                color={COLORS.damageType.burn}
                bold
              >
                <Box textAlign="center">
                  {partBurnsPercent > 0 ? partBurnsPercent : '--'}
                </Box>
              </Flex.Item>
            </Flex>
          </Flex.Item>
        </Flex>
      </LabeledList.Item>
    );
  }
  return null;
};
