import { Box, Table } from 'tgui-core/components';
import { pluralize } from 'tgui-core/string';

import {
  BrainDamageData,
  DisplayBloodPressureProps,
  DisplayOccupiedProps,
  DisplayTemperatureProps,
  DisplayTempImplantRowProps,
} from './type';

export const KeyHealthIndicators = (props) => {
  const {
    occupied,
    patient_status,
    blood_pressure_rendered,
    blood_pressure_status,
    blood_volume,
    body_temp,
    optimal_temp,
    embedded_objects,
    rad_stage,
    rad_dose,
    brain_damage,
  } = props.mobData;

  return (
    <>
      <Table>
        <DisplayBloodPressure
          occupied={occupied}
          patient_status={patient_status}
          blood_pressure_rendered={blood_pressure_rendered}
          blood_pressure_status={blood_pressure_status}
          blood_volume={blood_volume}
        />
        <DisplayTempImplantRow
          occupied={occupied}
          body_temp={body_temp}
          optimal_temp={optimal_temp}
          embedded_objects={embedded_objects}
        />
        {!!occupied && (
          <DisplayRads rad_stage={rad_stage} rad_dose={rad_dose} />
        )}
        <DisplayBrain occupied={occupied} status={brain_damage} />
      </Table>
      {!!occupied && (
        <DisplayEmbeddedObjects embedded_objects={embedded_objects} />
      )}
    </>
  );
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
    if (blood_volume <= 299) {
      pressure_color = 'red';
    } else if (blood_volume <= 414) {
      pressure_color = 'yellow';
    } else if (blood_volume <= 584) {
      pressure_color = 'green';
    } else if (blood_volume <= 665) {
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
          <>{occupied ? blood_volume.toString() : '--'} units</>
        )}
      </Table.Cell>
    </Table.Row>
  );
};

const DisplayTempImplantRow = (props: DisplayTempImplantRowProps) => {
  const { occupied, body_temp, optimal_temp, embedded_objects } = props;

  return (
    <Table.Row>
      <DisplayTemperature
        occupied={occupied}
        body_temp={body_temp}
        optimal_temp={optimal_temp}
      />
      <DisplayImplants
        occupied={occupied}
        embedded_objects={embedded_objects}
      />
    </Table.Row>
  );
};

const DisplayTemperature = (props: DisplayTemperatureProps) => {
  const { occupied, body_temp, optimal_temp } = props;
  let font_color = 'grey';
  if (occupied) {
    if (body_temp >= optimal_temp + 60) {
      font_color = 'red';
    } else if (body_temp >= optimal_temp + 30) {
      font_color = 'yellow';
    } else if (body_temp <= optimal_temp - 60) {
      font_color = 'purple';
    } else if (body_temp <= optimal_temp - 30) {
      font_color = 'blue';
    } else {
      font_color = 'green';
    }
  }

  return (
    <>
      <Table.Cell header textAlign="right">
        Temperature:
      </Table.Cell>
      <Table.Cell color={font_color} nowrap>
        {!!occupied &&
          (body_temp - 273.15).toPrecision(4) +
            '°C / ' +
            ((body_temp - 273.15) * 1.8 + 32).toPrecision(4) +
            '°F'}
        {!occupied && '--°C / --°F'}
      </Table.Cell>
    </>
  );
};

const DisplayImplants = (props) => {
  const { embedded_objects, occupied } = props;
  return (
    <>
      <Table.Cell header textAlign="right">
        Implants:
      </Table.Cell>
      <Table.Cell color={occupied ? 'white' : 'grey'}>
        {!!occupied &&
          `${embedded_objects['implant_count']} ${pluralize('implant', embedded_objects['implant_count'])}`}
        {!occupied && '--'}
      </Table.Cell>
    </>
  );
};

interface DisplayRadsProps {
  rad_stage: number;
  rad_dose;
}

const DisplayRads = (props: DisplayRadsProps) => {
  const { rad_stage, rad_dose } = props;
  let color: string | undefined;
  let bold = false;
  if (!rad_stage) {
    return null;
  }
  switch (rad_stage) {
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
        {rad_dose.toPrecision(6)} Sv
      </Table.Cell>
    </Table.Row>
  );
};

interface DisplayBrainProps extends DisplayOccupiedProps {
  status: BrainDamageData;
}

const DisplayBrain = (props: DisplayBrainProps) => {
  const { occupied, status } = props;
  if (!occupied || !['Okay', 'Missing'].includes(status.desc)) {
    return null;
  }
  return (
    <Table.Row>
      <Table.Cell header textAlign="right" color="pink" width={10}>
        Brain Damage:
      </Table.Cell>
      <Table.Cell width={10} color={status.color}>
        {status.desc}
      </Table.Cell>
      <Table.Cell header textAlign="right" width={10} nowrap>
        Neuron Cohesion:
      </Table.Cell>
      <Table.Cell>
        {(((120 - status.value) / 120) * 100).toFixed(2)}%
      </Table.Cell>
    </Table.Row>
  );
};

const DisplayEmbeddedObjects = (props) => {
  const { embedded_objects } = props;
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
