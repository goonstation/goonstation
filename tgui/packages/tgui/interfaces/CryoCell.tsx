/**
 * @file
 * @copyright 2023
 * @author Garash (https://github.com/Garash2k)
 * @license ISC
 */

import {
  AnimatedNumber,
  Box,
  Button,
  Dimmer,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { damageNum, HealthStat } from '../components/goonstation/HealthStat';
import { Window } from '../layouts';
import { KeyHealthIndicators } from './common/KeyHealthIndicators/index';
import { MobStatuses } from './common/MobStatus';
import { ReagentGraph, ReagentList } from './common/ReagentInfo';
import {
  getTemperatureColor,
  getTemperatureIcon,
} from './common/temperatureUtils';

interface CryoCellData {
  cellTemp: number;
  containerData; // Reagents
  hasDefib: BooleanLike;
  occupant: CryoOccupantData;
  ejectFullHealthOccupant: BooleanLike;
  status: BooleanLike;
  reagentScanActive: BooleanLike;
  reagentScanEnabled: BooleanLike;
  showBeakerContents: BooleanLike;
}

interface CryoOccupantData {
  occupied: BooleanLike;
  occupantStat: number;
  health: number;
  oxyDamage: number;
  toxDamage: number;
  burnDamage: number;
  bruteDamage: number;
  patient_status: number;
  blood_pressure_rendered: string;
  blood_pressure_status: string;
  body_temp: number;
  optimal_temp: number;
  embedded_objects: EmbeddedObjects;
  rad_stage: number;
  rad_dose: number;
  brain_damage: BrainDamage;
  blood_volume: number;
  reagents; // Reagents
  hasRoboticOrgans: boolean;
}

interface EmbeddedObjects {
  foreign_object_count: number;
  implant_count: number;
  has_chest_count: BooleanLike;
}

interface BrainDamage {
  value: number;
  desc: string;
  color: string;
}

export const CryoCell = () => {
  return (
    <Window width={485} height={575}>
      <Window.Content scrollable>
        <CryoCellControl />
        <Occupant />
        <Beaker />
      </Window.Content>
    </Window>
  );
};

const CryoCellControl = () => {
  const { act, data } = useBackend<CryoCellData>();
  const { cellTemp, status } = data;
  return (
    <Section title="Cryo Cell Control System">
      <Box textAlign="center">
        Current Cell Temperature
        <Box fontSize={2} color={getTemperatureColor(cellTemp)} mb="1rem">
          <Icon name={getTemperatureIcon(cellTemp)} pr={0.5} />
          <AnimatedNumber
            value={cellTemp - 273.15}
            format={(value) => value.toPrecision(4)}
          />
          °C
        </Box>
        <Button
          icon="power-off"
          color={status ? 'green' : 'red'}
          fontSize={1.25}
          textAlign="center"
          onClick={() => act('start')}
        >
          {status ? 'Activated' : 'Deactivated'}
        </Button>
      </Box>
    </Section>
  );
};

const Occupant = () => {
  const { act, data } = useBackend<CryoCellData>();
  const {
    occupant,
    reagentScanEnabled,
    reagentScanActive,
    hasDefib,
    ejectFullHealthOccupant,
  } = data;
  const occupantStatus = occupant ? MobStatuses[occupant.occupantStat] : null;

  return (
    <Section
      title="Occupant"
      buttons={
        <>
          {!!reagentScanEnabled && (
            <Button
              onClick={() => act('reagent_scan_active')}
              icon={reagentScanActive ? 'eye-slash' : 'eye'}
            >
              {reagentScanActive ? 'Hide' : 'Show'} Reagents
            </Button>
          )}
          {hasDefib && (
            <Button onClick={() => act('defib')} icon="bolt" color="yellow">
              Defibrillate
            </Button>
          )}
          <Button
            onClick={() => act('eject_occupant')}
            icon="eject"
            disabled={!occupant}
            color="green"
          >
            Eject
          </Button>
          <Button
            onClick={() => act('full_health_eject')}
            icon="refresh"
            color={ejectFullHealthOccupant ? 'green' : 'red'}
            tooltip="Automatically eject full-health occupants"
          >
            Auto-Eject
          </Button>
        </>
      }
    >
      {!!occupant && (
        <>
          <LabeledList>
            {!!occupantStatus && (
              <LabeledList.Item label="Status">
                <Icon color={occupantStatus.color} name={occupantStatus.icon} />
                {` ${occupantStatus.name}`}
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Overall Health">
              <ProgressBar
                value={occupant.health}
                ranges={{
                  good: [0.9, Infinity],
                  average: [0.5, 0.9],
                  bad: [-Infinity, 0.5],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Damage Breakdown">
              <HealthStat inline align="center" type="oxy" width={5}>
                {damageNum(occupant.oxyDamage)}
              </HealthStat>
              /
              <HealthStat inline align="center" type="toxin" width={5}>
                {damageNum(occupant.toxDamage)}
              </HealthStat>
              /
              <HealthStat inline align="center" type="burn" width={5}>
                {damageNum(occupant.burnDamage)}
              </HealthStat>
              /
              <HealthStat inline align="center" type="brute" width={5}>
                {damageNum(occupant.bruteDamage)}
              </HealthStat>
            </LabeledList.Item>
          </LabeledList>

          <Section title="Key Health Indicators" mt="0.5rem">
            <KeyHealthIndicators mobData={occupant} />
            {!!occupant.hasRoboticOrgans && (
              <Box textAlign="center">
                <Box bold fontSize={1.2} color="purple">
                  Unknown augmented organs detected.
                </Box>
              </Box>
            )}
          </Section>
        </>
      )}
      {occupant && occupant.reagents && (
        <>
          <ReagentGraph container={occupant.reagents} mt="0.5rem" />
          <ReagentList container={occupant.reagents} />
        </>
      )}
      {!occupant && <em>Unoccupied</em>}
    </Section>
  );
};

export const Beaker = () => {
  const { act, data } = useBackend<CryoCellData>();
  const { showBeakerContents, containerData } = data;
  return (
    <Section
      title="Beaker"
      buttons={
        <>
          <Button
            onClick={() => act('show_beaker_contents')}
            icon={showBeakerContents ? 'eye-slash' : 'eye'}
          >
            {showBeakerContents ? 'Hide' : 'Show'} Contents
          </Button>
          <Button
            onClick={() => act('eject')}
            icon="eject"
            disabled={!containerData}
            color="green"
          >
            Eject
          </Button>
        </>
      }
    >
      {!!showBeakerContents && (
        <>
          {containerData && (
            <>
              <ReagentGraph container={containerData} />
              <ReagentList container={containerData} />
              <Box
                fontSize={2}
                color={getTemperatureColor(containerData.temperature)}
                textAlign="center"
              >
                <Icon
                  name={getTemperatureIcon(containerData.temperature)}
                  pr={0.5}
                />
                <AnimatedNumber value={containerData.temperature} /> K
              </Box>
            </>
          )}
          {!containerData && (
            <Dimmer height="5rem">
              <Button
                icon="eject"
                fontSize={1.5}
                onClick={() => act('insert')}
                bold
              >
                Insert Beaker
              </Button>
            </Dimmer>
          )}
        </>
      )}
    </Section>
  );
};
