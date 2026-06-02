/**
 * @file
 * @copyright 2026
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { BooleanLike } from 'common/react';
import { Box, Section, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { HealthStat } from '../../components/goonstation/HealthStat';
import { Window } from '../../layouts';
import { KeyHealthIndicators } from '../common/KeyHealthIndicators/index';
import { ReagentGraph } from '../common/ReagentInfo';
import { capitalize, spaceUnderscores } from '../common/stringUtils';
import {
  DisplayAnatomicalAnomoliesProps,
  DisplayBloodstreamContentProps,
  DisplayLimbProps,
  DisplayLimbsProps,
  DisplayOrgansProps,
  LimbData,
  OperatingComputerData,
  OperatingComputerDisplayTitleProps,
  OrganData,
  PatientSummaryProps,
} from '../OperatingComputer/type';

export interface HealthAnalyzerData extends OperatingComputerData {
  organ_scan: BooleanLike;
  reagent_scan: BooleanLike;
}

export const HealthAnalyzer = () => {
  const { data } = useBackend<HealthAnalyzerData>();
  const { organ_scan, reagent_scan } = data;
  let height = 350;
  if (organ_scan) height += 200;
  if (reagent_scan) height += 90;
  return (
    <Window title="Health Analyzer" width={460} height={height}>
      <Window.Content scrollable>
        <PatientOverview />
      </Window.Content>
    </Window>
  );
};

// mob.stat parsing
const PatientSummary = (props: PatientSummaryProps) => {
  const { occupied, patient_status, isCrit } = props;
  let text = 'NONE';
  let color = 'grey';
  if (occupied) {
    if (patient_status === 2) {
      text = 'DEAD';
      color = 'red';
    } else if (isCrit) {
      text = 'CRIT';
      color = 'orange';
    } else if (patient_status === 0 || !patient_status) {
      text = 'STABLE';
      color = 'green';
    } else if (patient_status === 1) {
      text = 'UNCON'; // unconscious
      color = 'yellow';
    }
  }
  return (
    <Stack.Item width={20} textAlign="right">
      <Box fontSize={1}>Status</Box>
      <Box fontSize={1.5}>
        <Box color={color}>{text}</Box>
      </Box>
    </Stack.Item>
  );
};

const HealthSummary = (props) => {
  const { health_text, health_color } = props;

  return (
    <Stack.Item width={20} textAlign="right">
      <Box fontSize={1}>Overall Health</Box>
      <Box fontSize={1.5}>
        <Box color={health_color}>
          {health_text}
          <Box as="span" color="white">
            %
          </Box>
        </Box>
      </Box>
    </Stack.Item>
  );
};

const PatientOverview = () => {
  const { data } = useBackend<HealthAnalyzerData>();
  return (
    <Section>
      <DisplayTitle
        occupied={data.occupied}
        patient_name={data.patient_name}
        patient_health={data.current_health}
        patient_max_health={data.max_health}
        patient_status={data.patient_status}
      />
      <DisplayVitals />
      <Section title="Key Health Indicators">
        <KeyHealthIndicators mobData={data} />
      </Section>
      {!!data.reagent_scan && (
        <DisplayBloodstreamContent
          occupied={data.occupied}
          reagent_container={data.reagent_container}
        />
      )}
      {!!data.organ_scan && (
        <DisplayAnatomicalAnomolies
          occupied={data.occupied}
          organs={data.organ_status}
          limbs={data.limb_status}
        />
      )}
    </Section>
  );
};

const HealthNumber = (props) => {
  const { metric, value, title } = props;
  return (
    <Stack.Item width={25}>
      <HealthStat type={metric}>
        {title}
        <br />
        <Box fontSize={4}>{value}</Box>
      </HealthStat>
    </Stack.Item>
  );
};

const DisplayOrgans = (props: DisplayOrgansProps) => {
  const { occupied, organs } = props;
  if (!occupied) {
    return null;
  }
  return (
    <Stack.Item width={20}>
      <Table>
        <Table.Row>
          <Table.Cell header textAlign="right">
            Organ
          </Table.Cell>
          <Table.Cell header>Status</Table.Cell>
        </Table.Row>
        {organs.map((organ_data: OrganData) => {
          return (
            <DisplayOrgan
              key={organ_data['organ']}
              organ={organ_data['organ']}
              state={organ_data['state']}
              color={organ_data['color']}
              special={organ_data['special']}
            />
          );
        })}
      </Table>
    </Stack.Item>
  );
};

const DisplayOrgan = (props: OrganData) => {
  const { organ, state, color, special } = props;
  if (state === 'Okay' && !special) {
    return null;
  }
  return (
    <Table.Row>
      <Table.Cell header textAlign="right" width={10}>
        {capitalize(spaceUnderscores(organ))}:
      </Table.Cell>
      <Table.Cell
        width={10}
        color={color}
        bold={state === 'Missing' || state === 'Dead' || state === 'Critical'}
      >
        {state !== 'Okay' && state}
        {special && <Box color="white">{special}</Box>}
      </Table.Cell>
    </Table.Row>
  );
};

const DisplayLimbs = (props: DisplayLimbsProps) => {
  const { occupied, limbs } = props;
  if (!occupied) {
    return null;
  }
  return (
    <Stack.Item width={20}>
      <Table>
        <Table.Row>
          <Table.Cell header textAlign="right">
            Limb
          </Table.Cell>
          <Table.Cell header>Status</Table.Cell>
        </Table.Row>
        {limbs.map((limb_data: LimbData) => {
          return (
            <DisplayLimb
              key={limb_data['limb']}
              limb={limb_data['limb']}
              status={limb_data['status']}
            />
          );
        })}
      </Table>
    </Stack.Item>
  );
};

const DisplayLimb = (props: DisplayLimbProps) => {
  const { limb, status } = props;
  if (status === 'Okay') {
    return null;
  }
  return (
    <Table.Row>
      <Table.Cell header textAlign="right" width={10}>
        {capitalize(spaceUnderscores(limb))}:
      </Table.Cell>
      <Table.Cell
        width={10}
        color={status === 'Missing' ? 'red' : 'white'}
        bold={status === 'Missing'}
      >
        {status}
      </Table.Cell>
    </Table.Row>
  );
};

const DisplayVitals = () => {
  const { data } = useBackend<OperatingComputerData>();
  const oxy = data.occupied ? Math.floor(data.oxygen).toString() : '--';
  const toxin = data.occupied ? Math.floor(data.toxin).toString() : '--';
  const burn = data.occupied ? Math.floor(data.burn).toString() : '--';
  const brute = data.occupied ? Math.floor(data.brute).toString() : '--';

  return (
    <Section title="Vitals">
      <Stack textAlign="center">
        <HealthNumber title="Suffocation" value={oxy} metric="oxy" />
        <HealthNumber title="Toxin" value={toxin} metric="toxin" />
        <HealthNumber title="Burn" value={burn} metric="burn" />
        <HealthNumber title="Brute" value={brute} metric="brute" />
      </Stack>
    </Section>
  );
};

const DisplayAnatomicalAnomolies = (props: DisplayAnatomicalAnomoliesProps) => {
  const { occupied, organs, limbs } = props;
  return (
    <Section title="Anatomical Anomalies" color={!occupied && 'grey'}>
      <Stack>
        {!!occupied && <DisplayOrgans occupied={occupied} organs={organs} />}
        {!!occupied && <DisplayLimbs occupied={occupied} limbs={limbs} />}
        {!occupied && 'No Patient Detected'}
      </Stack>
    </Section>
  );
};

const DisplayBloodstreamContent = (props: DisplayBloodstreamContentProps) => {
  const { occupied, reagent_container } = props;
  return (
    <Section title="Bloodstream Contents">
      {!!occupied && <ReagentGraph container={reagent_container} />}
      {!occupied && 'No Patient Detected'}
    </Section>
  );
};

const DisplayTitle = (props: OperatingComputerDisplayTitleProps) => {
  const {
    occupied,
    patient_name,
    patient_health,
    patient_max_health,
    patient_status,
  } = props;
  const patient_name_color = occupied ? 'white' : 'grey';
  const is_crit = occupied && patient_health < 0;
  const patient_health_percent = occupied
    ? Math.floor((100 * patient_health) / patient_max_health)
    : 0;
  let patient_health_percent_text = '--';
  let color = 'grey';

  if (occupied) {
    if (patient_max_health <= 0) {
      color = 'purple';
      patient_health_percent_text = '???';
    } else {
      patient_health_percent_text = patient_health_percent.toString();
      if (patient_health_percent >= 51 && patient_health_percent <= 100) {
        color = 'green';
      } else if (patient_health_percent >= 1 && patient_health_percent <= 50) {
        color = 'yellow';
      } else {
        color = 'red';
      }
    }
  }

  return (
    <Stack>
      <Stack.Item width={60}>
        <Box fontSize={1} color={patient_name_color}>
          {patient_name ? patient_name : 'No Patient Detected'}
        </Box>
      </Stack.Item>
      <HealthSummary
        health_text={patient_health_percent_text}
        health_color={color}
      />
      <PatientSummary
        occupied={occupied}
        patient_status={patient_status}
        isCrit={!!is_crit}
      />
    </Stack>
  );
};
