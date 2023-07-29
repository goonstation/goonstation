/**
 * @file
 * @copyright 2023
 * @author Garash (https://github.com/Garash2k)
 * @license ISC
 */

import { useBackend } from "../backend";
import { Button, Box, Icon, AnimatedNumber, Section, LabeledList, ProgressBar, Dimmer, Table } from "../components";
import { Window } from '../layouts';
import { getTemperatureColor, getTemperatureIcon } from './common/temperatureUtils';
import { ReagentGraph, ReagentList } from './common/ReagentInfo';
import { HealthStat } from './common/HealthStat';
import { DisplayBloodPressure, DisplayTempImplantRow, DisplayRads, DisplayBrain, DisplayEmbeddedObjects } from '../interfaces/OperatingComputer/index';

export const CryoCell = (_props, context) => {
  return (
    <Window
      width={485}
      height={575}>
      <Window.Content scrollable>
        <CryoCellControl />
        <Occupant />
        <Beaker />
      </Window.Content>
    </Window>
  );
};

const CryoCellControl = (props, context) => {
  const { act, data } = useBackend(context);
  const { cellTemp, status } = data;
  return (
    <Section title="Cryo Cell Control System">
      <Box textAlign="center">
        Current Cell Temperature
        <Box
          fontSize={2}
          color={getTemperatureColor(cellTemp)}
          mb="1rem">
          <Icon name={getTemperatureIcon(cellTemp)} pr={0.5} />
          <AnimatedNumber value={(cellTemp - 273.15).toPrecision(4)} /> °C
        </Box>
        <Button
          icon="power-off"
          color={status ? "green" : "red"}
          fontSize={1.25}
          textAlign="center"
          onClick={() => act("start")}>
          {status ? "Activated" : "Deactivated"}
        </Button>
      </Box>
    </Section>);
};

const damageNum = num => !num || num <= 0 ? '0' : num.toFixed(1);

const OccupantStatus = {
  Conscious: 0,
  Unconscious: 1,
  Dead: 2,
};

const occupantStatuses = {
  [OccupantStatus.Conscious]: {
    name: 'Conscious',
    color: 'good',
    icon: 'check',
  },
  [OccupantStatus.Unconscious]: {
    name: 'Unconscious',
    color: 'average',
    icon: 'bed',
  },
  [OccupantStatus.Dead]: {
    name: 'Dead',
    color: 'bad',
    icon: 'skull',
  },
};

const Occupant = (props, context) => {
  const { act, data } = useBackend(context);
  const { occupant, reagentScanEnabled, reagentScanActive, hasDefib } = data;
  const occupantStatus = occupant ? occupantStatuses[occupant.occupantStat] : null;

  return (
    <Section title="Occupant"
      buttons={
        <>
          {!!reagentScanEnabled && (
            <Button onClick={() => act("reagent_scan_active")} icon={reagentScanActive ? "eye-slash" : "eye"}>
              {reagentScanActive ? "Hide" : "Show"} Reagents
            </Button>
          )}
          {hasDefib && (
            <Button onClick={() => act("defib")} icon="bolt" color="yellow">
              Defibrillate
            </Button>
          )}
          <Button onClick={() => act("eject_occupant")} icon="eject" disabled={!occupant} color="green">
            Eject
          </Button>
        </>
      }>

      {!!occupant && (
        <>
          <LabeledList>
            <LabeledList.Item label="Status">
              <Icon
                color={occupantStatus.color}
                name={occupantStatus.icon} />
              {" "}{occupantStatus.name}
            </LabeledList.Item>
            <LabeledList.Item label="Overall Health">
              <ProgressBar
                value={occupant.health}
                ranges={{
                  good: [0.9, Infinity],
                  average: [0.5, 0.9],
                  bad: [-Infinity, 0.5],
                }} />
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
            <Table>
              <DisplayBloodPressure
                occupied={occupant.occupied}
                patient_status={occupant.patient_status}
                blood_pressure_rendered={occupant.blood_pressure_rendered}
                blood_pressure_status={occupant.blood_pressure_status}
                blood_volume={occupant.blood_volume}
              />
              <DisplayTempImplantRow
                occupied={occupant.occupied}
                body_temp={occupant.body_temp}
                optimal_temp={occupant.optimal_temp}
                embedded_objects={occupant.embedded_objects}
              />
              { !!occupant.occupied && <DisplayRads rad_stage={occupant.rad_stage} rad_dose={occupant.rad_dose} />}
              <DisplayBrain
                occupied={occupant.occupied}
                status={occupant.brain_damage}
              />
            </Table>
            { !!occupant.occupied && <DisplayEmbeddedObjects embedded_objects={occupant.embedded_objects} />}
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

export const Beaker = (props, context) => {
  const { act, data } = useBackend(context);
  const { showBeakerContents, containerData } = data;
  return (
    <Section title="Beaker"
      buttons={
        <>
          <Button onClick={() => act("show_beaker_contents")} icon={showBeakerContents ? "eye-slash" : "eye"}>
            {showBeakerContents ? "Hide" : "Show"} Contents
          </Button>
          <Button onClick={() => act("eject")} icon="eject" disabled={!containerData} color="green">
            Eject
          </Button>
        </>
      }>
      {!!showBeakerContents && (
        <>
          {containerData && (
            <>
              <ReagentGraph container={containerData} />
              <ReagentList container={containerData} />
              <Box
                fontSize={2}
                color={getTemperatureColor(containerData.temperature)}
                textAlign="center">
                <Icon name={getTemperatureIcon(containerData.temperature)} pr={0.5} />
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
                bold>
                Insert Beaker
              </Button>
            </Dimmer>
          )}
        </>)}
    </Section>
  );
};
