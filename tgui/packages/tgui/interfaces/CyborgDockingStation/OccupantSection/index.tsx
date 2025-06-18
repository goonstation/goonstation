/**
 * @file
 * @copyright 2022
 * @author glowbold (https://github.com/pgmzeta)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { DockingAllowedButton } from '../DockingAllowedButton';
import type { CyborgDockingStationData, OccupantData } from '../type';
import { EyebotStatusView } from './EyebotStatusView';
import { HumanStatusView } from './HumanStatusView';
import { RobotStatusView } from './RobotStatusView';

export const OccupantSection = () => {
  const { act, data } = useBackend<CyborgDockingStationData>();
  const { cabling, fuel, occupant } = data;
  const hasOccupant = !!occupant?.name;
  const handleEjectOccupant = () => act('occupant-eject');
  const handleRenameOccupant = () => act('occupant-rename');
  const handleDescribeOccupant = () => act('occupant-describe');
  return (
    <Section title="Occupant">
      <Stack>
        <Stack.Item grow={1}>
          {hasOccupant ? (
            <OccupantSectionContents
              act={act}
              cabling={cabling}
              fuel={fuel}
              occupant={occupant}
              onEjectOccupant={handleEjectOccupant}
              onRenameOccupant={handleRenameOccupant}
              onDescribeOccupant={handleDescribeOccupant}
            />
          ) : (
            <div>No occupant</div>
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

interface OccupantSectionContentsProps {
  act: (action: string, payload?: object) => void;
  cabling: number;
  fuel: number;
  occupant: OccupantData;
  onEjectOccupant: () => void;
  onRenameOccupant: () => void;
  onDescribeOccupant: () => void;
}

const OccupantSectionContents = (props: OccupantSectionContentsProps) => {
  const {
    act,
    cabling,
    fuel,
    occupant,
    onEjectOccupant,
    onRenameOccupant,
    onDescribeOccupant,
  } = props;
  const occupantTypeDescription = occupantTypeDescriptionLens(occupant);
  return (
    <>
      <LabeledList>
        <LabeledList.Item
          label="Name"
          buttons={
            <>
              {occupant.kind === 'robot' && (
                <DockingAllowedButton
                  onClick={onRenameOccupant}
                  icon="edit"
                  tooltip="Change the occupant's designation"
                />
              )}
              {
                <DockingAllowedButton
                  onClick={onEjectOccupant}
                  icon="eject"
                  tooltip="Eject the occupant"
                />
              }
            </>
          }
        >
          <div
            style={{
              wordBreak: 'break-all',
            }}
          >
            {occupant.name}
          </div>
        </LabeledList.Item>
        {occupant.kind === 'robot' && (
          <LabeledList.Item
            label="Description"
            buttons={
              <DockingAllowedButton
                onClick={onDescribeOccupant}
                icon="edit"
                tooltip="Change the occupant's description"
              />
            }
          >
            <div
              style={{
                wordBreak: 'break-all',
              }}
            >
              {occupant.flavor_text}
            </div>
          </LabeledList.Item>
        )}
        <LabeledList.Item label="Type">
          {occupantTypeDescription}
        </LabeledList.Item>
      </LabeledList>
      <Section title="Status">
        {occupant.kind === 'robot' && (
          <RobotStatusView
            occupant={occupant}
            fuel={fuel}
            cabling={cabling}
            act={act}
          />
        )}
        {occupant.kind === 'human' && <HumanStatusView occupant={occupant} />}
        {occupant.kind === 'eyebot' && <EyebotStatusView occupant={occupant} />}
      </Section>
    </>
  );
};

const occupantTypeDescriptionLens = (occupant: OccupantData) => {
  switch (occupant.kind) {
    case 'robot':
      if (occupant.user === 'brain') {
        return 'Mk.2-Type Cyborg';
      }
      if (occupant.user === 'ai') {
        return 'Mk.2-Type AI Shell';
      }
      break;
    case 'human':
      return 'Mk.2-Type Carbon';
    case 'eyebot':
      return 'Mk.1-Type Eyebot';
    default:
      return 'Unknown';
  }
};
