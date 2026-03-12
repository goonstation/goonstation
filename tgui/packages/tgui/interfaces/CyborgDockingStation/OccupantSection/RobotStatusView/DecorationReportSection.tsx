/**
 * @file
 * @copyright 2022
 * @author glowbold (https://github.com/pgmzeta)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { ColorBox, LabeledList, Section } from 'tgui-core/components';

import { DockingAllowedButton } from '../../DockingAllowedButton';
import type { RobotCosmeticsData } from '../../type';

interface DecorationReportSectionProps {
  cosmetics: RobotCosmeticsData;
  onChangeCosmetic: Record<
    'head' | 'chest' | 'arms' | 'legs' | 'eyeGlow',
    () => void
  >;
  onChangePaintCosmetic: Record<'add' | 'change' | 'remove', () => void>;
}

export const DecorationReportSection = (
  props: DecorationReportSectionProps,
) => {
  const { cosmetics, onChangeCosmetic, onChangePaintCosmetic } = props;
  const {
    head: onChangeHead,
    chest: onChangeChest,
    arms: onChangeArms,
    legs: onChangeLegs,
    eyeGlow: onChangeEyeGlow,
  } = onChangeCosmetic;
  const {
    add: onAddPaint,
    change: onChangePaint,
    remove: onRemovePaint,
  } = onChangePaintCosmetic;
  return (
    <Section title="Decoration">
      <LabeledList>
        <LabeledList.Item
          label="Head"
          buttons={
            <DockingAllowedButton
              icon="sync-alt"
              tooltip="Change head decoration"
              onClick={onChangeHead}
            />
          }
        >
          {cosmetics.head || 'None'}
        </LabeledList.Item>
        <LabeledList.Item
          label="Chest"
          buttons={
            <DockingAllowedButton
              icon="sync-alt"
              tooltip="Change chest decoration"
              onClick={onChangeChest}
            />
          }
        >
          {cosmetics.chest || 'None'}
        </LabeledList.Item>
        <LabeledList.Item
          label="Arms"
          buttons={
            <DockingAllowedButton
              icon="sync-alt"
              tooltip="Change arms decoration"
              onClick={onChangeArms}
            />
          }
        >
          {cosmetics.arms || 'None'}
        </LabeledList.Item>
        <LabeledList.Item
          label="Legs"
          buttons={
            <DockingAllowedButton
              icon="sync-alt"
              tooltip="Change legs decoration"
              onClick={onChangeLegs}
            />
          }
        >
          {cosmetics.legs || 'None'}
        </LabeledList.Item>
        <LabeledList.Item
          label="Paint"
          buttons={
            <>
              {!cosmetics.paint && (
                <DockingAllowedButton
                  icon="plus"
                  tooltip="Add paint"
                  onClick={onAddPaint}
                />
              )}
              {cosmetics.paint && (
                <DockingAllowedButton
                  icon="tint"
                  tooltip="Change colour"
                  onClick={onChangePaint}
                />
              )}
              {cosmetics.paint && (
                <DockingAllowedButton
                  icon="minus"
                  tooltip="Remove paint"
                  onClick={onRemovePaint}
                />
              )}
            </>
          }
        >
          {cosmetics.paint ? (
            <ColorBox color={cosmetics.paint} />
          ) : (
            'No paint applied'
          )}
        </LabeledList.Item>
        <LabeledList.Item
          label="Eyes"
          buttons={
            <DockingAllowedButton
              icon="tint"
              tooltip="Change eye glow"
              onClick={onChangeEyeGlow}
            />
          }
        >
          <ColorBox
            color={
              'rgb(' +
              cosmetics.fx[0] +
              ',' +
              cosmetics.fx[1] +
              ',' +
              cosmetics.fx[2] +
              ')'
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
