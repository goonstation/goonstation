/**
 * @file
 * @copyright 2026
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */
import { Box, Collapsible, Section, Stack } from 'tgui-core/components';

import { ReagentContainer, ReagentGraph, ReagentList } from '../ReagentInfo';
import { DisplayOccupiedProps } from './type';

const STAT_ALIVE: number = 0;
const STAT_UNCONSCIOUS: number = 1;
const STAT_DEAD: number = 2;

type PatientSummaryProps = DisplayOccupiedProps & {
  patient_status: number;
  isCrit: boolean;
};

export const PatientSummary = (props: PatientSummaryProps) => {
  const { occupied, patient_status, isCrit } = props;
  let text = 'NONE';
  let color = 'grey';
  if (occupied) {
    if (patient_status === STAT_DEAD) {
      text = 'DEAD';
      color = 'red';
    } else if (isCrit) {
      text = 'CRIT';
      color = 'orange';
    } else if (patient_status === STAT_ALIVE || !patient_status) {
      text = 'STABLE';
      color = 'green';
    } else if (patient_status === STAT_UNCONSCIOUS) {
      text = 'UNCON'; // unconscious
      color = 'yellow';
    }
  }
  return (
    <Stack.Item width={20} textAlign="right">
      <Box>Status</Box>
      <Box fontSize={1.5}>
        <Box color={color}>{text}</Box>
      </Box>
    </Stack.Item>
  );
};

interface HealthSummaryProps {
  health_text: string;
  health_color: string;
}

export const HealthSummary = (props: HealthSummaryProps) => {
  const { health_text, health_color } = props;

  return (
    <Stack.Item width={25} textAlign="right">
      <Box>Overall Health</Box>
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

type DisplayPatientTitleProps = DisplayOccupiedProps & {
  patient_name: string;
  patient_health: number;
  patient_max_health: number;
  patient_status: number;
};

export const DisplayPatientTitle = (props: DisplayPatientTitleProps) => {
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
    <Section>
      <Stack>
        <Stack.Item width={60}>
          <Box>Patient</Box>
          <Box fontSize={1.5} color={patient_name_color}>
            {occupied ? patient_name : 'No Patient Detected'}
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
    </Section>
  );
};

type DisplayBloodstreamContentProps = DisplayOccupiedProps & {
  reagent_container: ReagentContainer | null;
  show_type: 'graph' | 'list' | 'both';
};

export const DisplayBloodstreamContent = (
  props: DisplayBloodstreamContentProps,
) => {
  const { occupied, show_type, reagent_container } = props;
  return (
    <Collapsible
      sideIcon="flask"
      open
      title="Bloodstream Contents"
      color={!occupied && 'grey'}
    >
      <Section>
        {!occupied && 'No Patient Detected.'}
        {!!occupied && (show_type === 'graph' || show_type === 'both') && (
          <ReagentGraph container={reagent_container} />
        )}
        {!!occupied && (show_type === 'list' || show_type === 'both') && (
          <ReagentList container={reagent_container} />
        )}
      </Section>
    </Collapsible>
  );
};
