/**
 * @file
 * @copyright 2023
 * @author Garash (https://github.com/Garash2k)
 * @license ISC
 */

import { useBackend } from "../backend";
// import { , Stack } from "../components";
import { Button, Box, Icon, AnimatedNumber, Section, LabeledList, ProgressBar } from "../components";
import { Window } from '../layouts';
import { getTemperatureColor, getTemperatureIcon } from './common/temperatureUtils';
import { ReagentGraph, ReagentList } from './common/ReagentInfo';
import { HealthStat } from './common/HealthStat';

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

export const CryoCell = (_props, context) => {

  const { act, data } = useBackend(context);
  const { occupant, cellTemp, status,
    showBeakerContents, reagentScanEnabled, reagentScanActive,
    containerData,
    hasDefib } = data;

  const occupantStatus = occupant ? occupantStatuses[occupant.occupantStat] : null;

  return (
    <Window
      width={450}
      height={550}>
      <Window.Content scrollable>
        <Section title="Cryo Cell Control System">
          <Box textAlign="center">
            Current Cell Temperature
            <Box
              fontSize={2}
              color={getTemperatureColor(cellTemp)}
              mb="1rem">
              <Icon name={getTemperatureIcon(cellTemp)} pr={0.5} />
              <AnimatedNumber value={cellTemp} /> K
            </Box>
            <Button
              icon="power-off"
              color={status ? "red" : "green"}
              fontSize={1.25}
              textAlign="center"
              onClick={() => act("start")}>
              {status ? "Deactivate" : "Activate"}
            </Button>
          </Box>
        </Section>

        <Section title="Occupant"
          buttons={
            <>
              {!!reagentScanEnabled && (
                <Button onClick={() => act("reagent_scan_active")} icon={reagentScanActive ? "eye-slash" : "eye"}>
                  {reagentScanActive ? "Hide" : "Show"} Reagents
                </Button>
              )}
              {hasDefib && (
                <Button onClick={() => act("defib")} icon="bolt">
                  Defibrillate
                </Button>
              )}
              <Button onClick={() => act("eject_occupant")} icon="eject">
                Eject
              </Button>
            </>
          }>

          {!!occupant && (
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
              {occupant.blood_data && (
                <LabeledList.Item label="Blood Pressure">
                  <Box color={occupant.pressure_color}>
                    {occupant.blood_data}
                  </Box>
                </LabeledList.Item>
              )}
              <LabeledList.Item label="Temperature">
                <Box color={occupant.temperature_color}>
                  {(occupant.bodytemperature - 273.15).toPrecision(4) + "°C / " + ((occupant.bodytemperature - 273.15) * 1.8 + 32).toPrecision(4) + "°F"}
                </Box>
              </LabeledList.Item>
              {occupant.total_blood && (
                <LabeledList.Item label="Blood Volume">
                  <Box color={occupant.pressure_color}>
                    {occupant.total_blood} units
                  </Box>
                </LabeledList.Item>
              )}
            </LabeledList>
          )}
          {occupant && occupant.reagents && (
            <>
              <ReagentGraph container={occupant.reagents} mt="0.5rem" />
              <ReagentList container={occupant.reagents} />
            </>
          )}
        </Section>

        <Section title="Beaker"
          buttons={
            <>
              <Button onClick={() => act("show_beaker_contents")} icon={showBeakerContents ? "eye-slash" : "eye"}>
                {showBeakerContents ? "Hide" : "Show"} Contents
              </Button>
              <Button onClick={() => act("eject")} icon="eject">
                Eject
              </Button>
            </>
          }>
          {containerData && !!showBeakerContents && (
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
            </>)}
        </Section>
      </Window.Content>
    </Window>
  );
};
