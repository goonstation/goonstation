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
  Collapsible,
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
import { DisplayBloodstreamContent } from './common/health';
import { KeyHealthIndicators } from './common/health/key_indicators';
import { HealthData } from './common/health/type';
import { MobStatuses } from './common/MobStatus';
import {
  ReagentContainer,
  ReagentGraph,
  ReagentList,
} from './common/ReagentInfo';
import {
  getTemperatureColor,
  getTemperatureIcon,
} from './common/temperatureUtils';

interface CryoCellData {
  cellTemp: number;
  containerData: ReagentContainer;
  hasDefib: BooleanLike;
  occupant: HealthData;
  ejectFullHealthOccupant: BooleanLike;
  status: BooleanLike;
  showBeakerContents: BooleanLike;
  occupant_data: HealthData;
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
  const { occupant, hasDefib, ejectFullHealthOccupant } = data;
  const occupantStatus = occupant ? MobStatuses[occupant.patient_status] : null;

  return (
    <Section
      title="Occupant"
      buttons={
        <>
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
                value={occupant.current_health / occupant.max_health}
                ranges={{
                  good: [0.9, Infinity],
                  average: [0.5, 0.9],
                  bad: [-Infinity, 0.5],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Damage Breakdown">
              <HealthStat inline align="center" type="oxy" width={5}>
                {damageNum(occupant.oxygen)}
              </HealthStat>
              /
              <HealthStat inline align="center" type="toxin" width={5}>
                {damageNum(occupant.toxin)}
              </HealthStat>
              /
              <HealthStat inline align="center" type="burn" width={5}>
                {damageNum(occupant.burn)}
              </HealthStat>
              /
              <HealthStat inline align="center" type="brute" width={5}>
                {damageNum(occupant.brute)}
              </HealthStat>
            </LabeledList.Item>
          </LabeledList>

          <KeyHealthIndicators
            occupied={data.occupant.occupied}
            patient_status={data.occupant.patient_status}
            blood_pressure_rendered={data.occupant.blood_pressure_rendered}
            blood_pressure_status={data.occupant.blood_pressure_status}
            blood_volume={data.occupant.blood_volume}
            bleeding={data.occupant.bleeding}
            body_temp={data.occupant.body_temp}
            optimal_temp={data.occupant.optimal_temp}
            embedded_objects={data.occupant.embedded_objects}
            rad_stage={data.occupant.rad_stage}
            rad_dose={data.occupant.rad_dose}
            brain_damage={data.occupant.brain_damage}
          />
        </>
      )}
      {!!occupant && occupant.reagent_container && (
        <DisplayBloodstreamContent
          occupied={data.occupant.occupied}
          show_type="both"
          reagent_container={data.occupant.reagent_container}
        />
      )}
      {!occupant && <em>Unoccupied</em>}
    </Section>
  );
};

export const Beaker = () => {
  const { act, data } = useBackend<CryoCellData>();
  const { containerData } = data;
  return (
    <Section
      title="Beaker"
      buttons={
        <Button
          onClick={() => act('eject')}
          icon="eject"
          disabled={!containerData}
          color="green"
        >
          Eject
        </Button>
      }
    >
      <Collapsible title={'Beaker Contents'} icon="flask">
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
              <AnimatedNumber
                value={
                  containerData.temperature ? containerData.temperature : 273
                }
              />{' '}
              K
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
      </Collapsible>
    </Section>
  );
};
