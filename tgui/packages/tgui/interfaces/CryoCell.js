/**
 * @file
 * @copyright 2023
 * @author Garash (https://github.com/Garash2k)
 * @license ISC
 */

import { useBackend } from "../backend";
import { AnimatedNumber, Box, Button, Dimmer, Icon, LabeledList, ProgressBar, Section } from "../components";
import { Window } from '../layouts';
import { getTemperatureColor, getTemperatureIcon } from './common/temperatureUtils';
import { ReagentGraph, ReagentList } from './common/ReagentInfo';
import { damageNum, HealthStat } from './common/HealthStat';
import { MobStatuses } from './common/MobStatus';
import { KeyHealthIndicators } from './common/KeyHealthIndicators/index';

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

const Occupant = (props, context) => {
  const { act, data } = useBackend(context);
  const { occupant, reagentScanEnabled, reagentScanActive, hasDefib } = data;
  const occupantStatus = occupant ? MobStatuses[occupant.occupantStat] : null;

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
            <KeyHealthIndicators mobData={occupant} />
            {!!occupant.hasRoboticOrgans && (
              <Box textAlign="center">
                <Box bold fontSize={1.2} color="purple">Unknown augmented organs detected.</Box>
              </Box>)}
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
