/**
 * @file
 * @copyright 2026
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { Box, Collapsible, Section, Stack, Table } from 'tgui-core/components';

import { capitalize, spaceUnderscores } from '../stringUtils';
import { DisplayOccupiedProps, LimbData, LimbStatus, OrganData } from './type';

type DisplayAnatomicalAnomaliesProps = DisplayOccupiedProps & {
  organs: OrganData[] | null;
  limbs: LimbData[] | null;
};

export const DisplayAnatomicalAnomalies = (
  props: DisplayAnatomicalAnomaliesProps,
) => {
  const { occupied, organs, limbs } = props;
  return (
    <Collapsible
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

type DisplayLimbsProps = DisplayOccupiedProps & {
  limbs: LimbData[] | null;
};

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
          limbs.map((limb_data: LimbData, index) => {
            return <DisplayLimb key={index} limb={limb_data} />;
          })}
      </Table>
    </Stack.Item>
  );
};

interface DisplayLimbProps {
  limb: LimbData;
}

const DisplayLimb = (props: DisplayLimbProps) => {
  const { limb } = props;
  if (limb.status === LimbStatus.Okay) {
    return null;
  }
  return (
    <Table.Row>
      <Table.Cell header textAlign="right" width={10}>
        {capitalize(spaceUnderscores(limb.limb_name))}:
      </Table.Cell>
      <Table.Cell
        width={10}
        color={limb.status === LimbStatus.Missing ? 'red' : 'white'}
        bold={limb.status === LimbStatus.Missing}
      >
        {limb.status}
      </Table.Cell>
    </Table.Row>
  );
};

type DisplayOrgansProps = DisplayOccupiedProps & {
  organs: OrganData[] | null;
};

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
          organs.map((organ_data: OrganData, index) => {
            return <DisplayOrgan key={index} organ={organ_data} />;
          })}
      </Table>
    </Stack.Item>
  );
};

interface DisplayOrganProps {
  organ: OrganData;
}

const DisplayOrgan = (props: DisplayOrganProps) => {
  const { organ } = props;
  if (organ.damage === 0 && organ.special === '') {
    return null; // only appears if damaged or special/missing
  }
  let color = 'grey';
  let state = '???';
  let bold = false;
  if (organ.special === 'Missing') {
    color = 'red';
    state = 'Missing';
  } else {
    const pct = organ.damage / organ.max_health;
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
        {capitalize(spaceUnderscores(organ.organ_name))}:
      </Table.Cell>
      <Table.Cell width={10} color={color} bold={bold}>
        {state !== 'Okay' && state}
        {organ.special && organ.special !== 'Missing' && (
          <Box color="white">{organ.special}</Box>
        )}
      </Table.Cell>
    </Table.Row>
  );
};
