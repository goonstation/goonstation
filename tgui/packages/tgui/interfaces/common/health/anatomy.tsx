/**
 * @file
 * @copyright 2026
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { Box, Collapsible, Section, Stack, Table } from 'tgui-core/components';

import { capitalize, spaceUnderscores } from '../stringUtils';
import { DisplayOccupiedProps, LimbData, OrganData } from './type';

interface DisplayAnatomicalAnomaliesProps extends DisplayOccupiedProps {
  organs: OrganData[] | null;
  limbs: LimbData[] | null;
}

export const DisplayAnatomicalAnomalies = (
  props: DisplayAnatomicalAnomaliesProps,
) => {
  const { occupied, organs, limbs } = props;
  return (
    <Collapsible
      fontSize={1.2}
      open
      sideIcon="lungs"
      title="Anatomical Anomalies"
      color={!occupied && 'grey'}
    >
      <Section>
        <Stack>
          {!!occupied && <DisplayOrgans occupied={occupied} organs={organs} />}
          {!!occupied && <DisplayLimbs occupied={occupied} limbs={limbs} />}
          {!occupied && 'No Patient Detected.'}
        </Stack>
      </Section>
    </Collapsible>
  );
};

interface DisplayLimbsProps extends DisplayOccupiedProps {
  limbs: LimbData[] | null;
}

export const DisplayLimbs = (props: DisplayLimbsProps) => {
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
        {limbs &&
          limbs.map((limb_data: LimbData) => {
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

interface DisplayLimbProps {
  limb: string;
  status: string;
}

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

interface DisplayOrgansProps extends DisplayOccupiedProps {
  organs: OrganData[] | null;
}

export const DisplayOrgans = (props: DisplayOrgansProps) => {
  const { occupied, organs } = props;
  return (
    <Stack.Item width={20}>
      <Table>
        <Table.Row>
          <Table.Cell header textAlign="right">
            Organ
          </Table.Cell>
          <Table.Cell header>Status</Table.Cell>
        </Table.Row>
        {occupied &&
          organs &&
          organs.map((organ_data: OrganData) => {
            return (
              <DisplayOrgan
                key={organ_data['organ']}
                organ={organ_data['organ']}
                damage={organ_data['damage']}
                max_health={organ_data['max_health']}
                special={organ_data['special']}
              />
            );
          })}
      </Table>
    </Stack.Item>
  );
};

const DisplayOrgan = (props: OrganData) => {
  const { organ, damage, max_health, special } = props;
  if (damage === 0 && special === '') {
    return null; // only appears if damaged or special/missing
  }
  let color = 'grey';
  let state = '???';
  let bold = false;
  if (special === 'Missing') {
    color = 'red';
    state = 'Missing';
  } else {
    const pct = damage / max_health;
    if (pct > 1) {
      color = 'red';
      state = 'Dead';
      bold = true;
    } else if (pct > 0.9) {
      color = 'red';
      state = 'Critical';
      bold = true;
    } else if (pct > 0.65) {
      color = 'orange';
      state = 'Sigificant';
    } else if (pct > 0.3) {
      color = 'yellow';
      state = 'Moderate';
    } else if (pct > 0) {
      color = 'green';
      state = 'Minor';
    } else {
      color = 'Green';
      state = 'Okay';
    }
  }

  return (
    <Table.Row>
      <Table.Cell header textAlign="right" width={10}>
        {capitalize(spaceUnderscores(organ))}:
      </Table.Cell>
      <Table.Cell width={10} color={color} bold={bold}>
        {state !== 'Okay' && state}
        {special && special !== 'Missing' && <Box color="white">{special}</Box>}
      </Table.Cell>
    </Table.Row>
  );
};
