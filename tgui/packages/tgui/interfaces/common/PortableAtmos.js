import { useBackend } from '../../backend';
import { Fragment } from 'inferno';
import { Box, Section, LabeledList, Button, AnimatedNumber } from '../../components';
import { PressureBar } from './PressureBar';

export const PortableBasicInfo = props => {
  const {
    connected,
    pressure,
    maxPressure,
  } = props;

  return (
    <Section
      title="Status">
      <LabeledList>
        <LabeledList.Item label="Pressure">
          <AnimatedNumber value={pressure} />
          {' kPa'}
        </LabeledList.Item>
        <LabeledList.Item
          label="Port"
          color={connected ? 'good' : 'average'}>
          {connected ? 'Connected' : 'Not Connected'}
        </LabeledList.Item>
      </LabeledList>
      <PressureBar
        pressure={pressure}
        maxPressure={maxPressure} />
    </Section>
  );
};

export const PortableHoldingTank = props => {

  const {
    holding,
    onEjectTank,
  } = props;

  return (
    <Section
      title="Holding Tank"
      minHeight="82px"
      buttons={(
        <Button
          icon="eject"
          content="Eject"
          disabled={!holding}
          onClick={() => onEjectTank()} />
      )}>
      {holding ? (
        <Fragment>
          <LabeledList>
            <LabeledList.Item label="Label">
              {holding.name}
            </LabeledList.Item>
            <LabeledList.Item label="Pressure">
              <AnimatedNumber
                value={holding.pressure} />
              {' kPa'}
            </LabeledList.Item>
          </LabeledList>
          <PressureBar
            pressure={holding.pressure}
            maxPressure={holding.maxPressure} />
        </Fragment>
      ) : (
        <Box color="average">
          No holding tank
        </Box>
      )}
    </Section>
  );
};
