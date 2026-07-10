/**
 * @file
 * @copyright 2026
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */
import { Box, Icon, Section, Table } from 'tgui-core/components';
import { pluralize } from 'tgui-core/string';

import { BrainDamage, DisplayOccupiedProps, EmbeddedObjects } from './type';

const BRAIN_DAMAGE_MINOR: number = 20;
const BRAIN_DAMAGE_MODERATE: number = 40;
const BRAIN_DAMAGE_MAJOR: number = 60;
const BRAIN_DAMAGE_SEVERE: number = 80;
const BRAIN_DAMAGE_LETHAL: number = 100;
const BRAIN_DAMAGE_DEATH: number = 120;

const BLOOD_VOLUME_VERY_LOW: number = 299;
const BLOOD_VOLUME_LOW: number = 414;
const BLOOD_VOLUME_HIGH: number = 584;
const BLOOD_VOLUME_VERY_HIGH: number = 665;

type KeyHealthIndicatorsProps = DisplayOccupiedProps & {
  patient_status: number;
  blood_pressure_rendered: string | null;
  blood_pressure_status: string | null;
  blood_volume: number | null;
  bleeding: number | null;
  body_temp: number | string;
  optimal_temp: number | string;
  rad_stage: number;
  rad_dose: number;
  brain_damage: BrainDamage;
  embedded_objects: EmbeddedObjects | null;
};

export const KeyHealthIndicators = (props: KeyHealthIndicatorsProps) => {
  const {
    occupied,
    patient_status,
    blood_pressure_rendered,
    blood_pressure_status,
    blood_volume,
    body_temp,
    optimal_temp,
    bleeding,
    embedded_objects,
    rad_stage,
    rad_dose,
    brain_damage,
  } = props;

  return (
    <Section title="Key Health Indicators">
      <Table>
        <DisplayBloodPressure
          occupied={occupied}
          patient_status={patient_status}
          blood_pressure_rendered={blood_pressure_rendered}
          blood_pressure_status={blood_pressure_status}
          blood_volume={blood_volume}
        />
        <DisplayTemperatureBleedingRow
          occupied={occupied}
          body_temp={body_temp}
          optimal_temp={optimal_temp}
          bleeding={bleeding}
        />
        <DisplayRads rad_stage={rad_stage} rad_dose={rad_dose} />
        <DisplayBrain occupied={occupied} brain_damage={brain_damage} />
      </Table>
      {!!occupied && (
        <DisplayEmbeddedObjects embedded_objects={embedded_objects} />
      )}
    </Section>
  );
};

type DisplayBloodPressureProps = DisplayOccupiedProps & {
  patient_status: number;
  blood_pressure_rendered: string | null;
  blood_pressure_status: string | null;
  blood_volume: number | null;
};

const DisplayBloodPressure = (props: DisplayBloodPressureProps) => {
  const {
    occupied,
    patient_status,
    blood_pressure_rendered,
    blood_pressure_status,
    blood_volume,
  } = props;
  let pressure_color = 'grey';
  if (occupied) {
    if (blood_volume === null) {
    } else if (blood_volume <= BLOOD_VOLUME_VERY_LOW) {
      pressure_color = 'red';
    } else if (blood_volume <= BLOOD_VOLUME_LOW) {
      pressure_color = 'yellow';
    } else if (blood_volume <= BLOOD_VOLUME_HIGH) {
      pressure_color = 'green';
    } else if (blood_volume <= BLOOD_VOLUME_VERY_HIGH) {
      pressure_color = 'yellow';
    } else {
      pressure_color = 'red';
    }
  }

  return (
    <Table.Row>
      <Table.Cell header textAlign="right" width={10} nowrap>
        Blood Pressure:
      </Table.Cell>
      <Table.Cell width={10} color={pressure_color} nowrap>
        {!!occupied &&
          patient_status !== 2 &&
          `${blood_pressure_rendered} (${blood_pressure_status})`}
        {!occupied && '--/--'}
      </Table.Cell>

      <Table.Cell header textAlign="right" width={10} nowrap>
        {typeof blood_volume === 'number' && <>Blood Volume:</>}
      </Table.Cell>
      <Table.Cell width={10} color={pressure_color}>
        {typeof blood_volume === 'number' && (
          <>{occupied ? blood_volume.toString() : '--'}u</>
        )}
      </Table.Cell>
    </Table.Row>
  );
};

type DisplayTemperatureBleedingRowProps = DisplayOccupiedProps & {
  body_temp: number | string;
  optimal_temp: number | string;
  bleeding: number | null;
};

const DisplayTemperatureBleedingRow = (
  props: DisplayTemperatureBleedingRowProps,
) => {
  const { occupied, body_temp, optimal_temp, bleeding } = props;
  return (
    <Table.Row>
      <DisplayTemperature
        occupied={occupied}
        body_temp={body_temp}
        optimal_temp={optimal_temp}
      />
      <DisplayBleeding occupied={occupied} bleeding={bleeding} />
    </Table.Row>
  );
};

type DisplayTemperatureProps = DisplayOccupiedProps & {
  body_temp: number | string;
  optimal_temp: number | string;
};

const DisplayTemperature = (props: DisplayTemperatureProps) => {
  const { occupied, body_temp, optimal_temp } = props;
  let font_color = 'grey';
  let icon = '';
  if (occupied) {
    if (body_temp === null) {
    } else if (
      'string' === typeof body_temp ||
      'string' === typeof optimal_temp
    ) {
      icon = 'question';
    } else if (body_temp >= optimal_temp + 60) {
      font_color = 'red';
      icon = 'temperature-arrow-up';
    } else if (body_temp >= optimal_temp + 30) {
      font_color = 'yellow';
      icon = 'temperature-high';
    } else if (body_temp <= optimal_temp - 60) {
      font_color = 'purple';
      icon = 'temperature-arrow-down';
    } else if (body_temp <= optimal_temp - 30) {
      font_color = 'blue';
      icon = 'temperature-low';
    } else {
      font_color = 'green';
      icon = 'temperature-quarter';
    }
  }

  return (
    <>
      <Table.Cell header textAlign="right">
        Temperature:
      </Table.Cell>

      <Table.Cell color={font_color} nowrap>
        <Icon name={icon} />
        {!occupied && '--°C / --°F'}
        {!!occupied &&
          'string' === typeof body_temp &&
          `${body_temp} (${optimal_temp})`}
        {!!occupied &&
          'string' !== typeof body_temp &&
          (body_temp - 273.15).toPrecision(4) +
            '°C (' +
            ((body_temp - 273.15) * 1.8 + 32).toPrecision(4) +
            '°F)'}
      </Table.Cell>
    </>
  );
};

type DisplayBloodLossProps = DisplayOccupiedProps & {
  bleeding: number | null;
};

const DisplayBleeding = (props: DisplayBloodLossProps) => {
  const { bleeding, occupied } = props;
  return (
    <>
      <Table.Cell header textAlign="right">
        Blood Loss:
      </Table.Cell>
      <Table.Cell color={occupied ? 'white' : 'grey'}>
        {!!occupied && `${bleeding}u`}
        {!occupied && '--'}
      </Table.Cell>
    </>
  );
};

interface DisplayRadsProps {
  rad_stage: number;
  rad_dose: number;
}

const DisplayRads = (props: DisplayRadsProps) => {
  const { rad_stage, rad_dose } = props;
  let color: string | undefined;
  let bold = false;
  if (!rad_dose || rad_dose === 0 || rad_dose === null) {
    return null;
  }
  switch (rad_stage) {
    case null:
    case 0:
      return null; // only show if they have enough radiation to be stage 1
    case 1:
      color = 'yellow';
      break;
    case 2:
      color = 'orange';
      break;
    case 3:
      color = 'orange';
      bold = true;
      break;
    case 4:
    case 5:
    case 6:
      color = 'red';
      bold = true;
      break;
    default:
      break;
  }
  return (
    <Table.Row>
      <Table.Cell header textAlign="right" color="yellow" width={10}>
        Radiation:
      </Table.Cell>
      <Table.Cell width={10} color={color} bold={bold}>
        Stage {rad_stage}
      </Table.Cell>
      <Table.Cell header textAlign="right" width={10}>
        Effective Dose:
      </Table.Cell>
      <Table.Cell width={10} nowrap>
        {rad_dose ? rad_dose.toPrecision(4) : 0} Sv
      </Table.Cell>
    </Table.Row>
  );
};

type DisplayBrainProps = DisplayOccupiedProps & {
  brain_damage: BrainDamage;
};

const DisplayBrain = (props: DisplayBrainProps) => {
  const { occupied, brain_damage } = props;
  if (!occupied || brain_damage === null) {
    return null;
  }
  let brain_text = 'Missing';
  let brain_color = 'red';

  if (brain_damage === 'Missing') {
    return (
      <Table.Row>
        <Table.Cell header textAlign="right" color="pink" width={10}>
          Brain Damage:
        </Table.Cell>
        <Table.Cell width={10} color={brain_color}>
          {brain_text}
        </Table.Cell>
        <Table.Cell header textAlign="right" width={10} nowrap>
          Neuron Cohesion:
        </Table.Cell>
        <Table.Cell>N/A</Table.Cell>
      </Table.Row>
    );
  }

  const brain_damage_amount = Number(brain_damage);
  if (brain_damage_amount === 0) {
    return null; // only show if there is any brain damage
  } else if (brain_damage_amount > BRAIN_DAMAGE_LETHAL) {
    brain_text = 'Braindead';
  } else if (brain_damage_amount > BRAIN_DAMAGE_SEVERE) {
    brain_text = 'Severe';
  } else if (brain_damage_amount >= BRAIN_DAMAGE_MAJOR) {
    brain_color = 'yellow';
    brain_text = 'Major';
  } else if (brain_damage_amount >= BRAIN_DAMAGE_MODERATE) {
    brain_color = 'orange';
    brain_text = 'Moderate';
  } else if (brain_damage_amount >= BRAIN_DAMAGE_MINOR) {
    brain_color = 'yellow';
    brain_text = 'Minor';
  } else if (brain_damage_amount > 0) {
    brain_color = 'green';
    brain_text = 'Okay';
  }

  return (
    <Table.Row>
      <Table.Cell header textAlign="right" color="pink" width={10}>
        Brain Damage:
      </Table.Cell>
      <Table.Cell width={10} color={brain_color}>
        {brain_text}
      </Table.Cell>
      <Table.Cell header textAlign="right" width={10} nowrap>
        Neuron Cohesion:
      </Table.Cell>
      <Table.Cell>
        {(
          ((BRAIN_DAMAGE_DEATH - brain_damage_amount) / BRAIN_DAMAGE_DEATH) *
          100
        ).toFixed(2) + '%'}
      </Table.Cell>
    </Table.Row>
  );
};

interface DisplayEmbeddedObjectsProps {
  embedded_objects: EmbeddedObjects | null;
}

const DisplayEmbeddedObjects = (props: DisplayEmbeddedObjectsProps) => {
  const { embedded_objects } = props;
  if (embedded_objects === null) {
    return null; // only appears if an object is detected
  }
  return (
    <Box textAlign="center">
      {!!embedded_objects['has_chest_object'] && (
        <Box bold fontSize={1.2} color="red">
          Sizable foreign object located below sternum!
        </Box>
      )}
      {!!embedded_objects['foreign_object_count'] && (
        <Box bold fontSize={1.2} color="red">
          {`Foreign ${pluralize('object', embedded_objects['foreign_object_count'])} detected!`}
        </Box>
      )}
    </Box>
  );
};
