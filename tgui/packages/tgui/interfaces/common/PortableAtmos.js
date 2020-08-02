import { useBackend } from '../../backend';
import { Fragment } from 'inferno';
import { Box, Section, LabeledList, Button, AnimatedNumber } from '../../components';
import { PressureBar } from './PressureBar';

export const PortableBasicInfo = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    connected,
    holding = null,
    pressure,
    max_pressure,
  } = data;

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
      <br />
      <PressureBar
        pressure={pressure}
        max_pressure={max_pressure} />
    </Section>
  );
};

export const PortableHoldingTank = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    holding,
  } = data;

  return (
    <Section
      title="Holding Tank"
      minHeight="82px"
      buttons={(
        <Button
          icon="eject"
          content="Eject"
          disabled={!holding}
          onClick={() => act('eject-tank')} />
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
          <br />
          <PressureBar
            pressure={holding.pressure}
            max_pressure={holding.max_pressure} />
        </Fragment>
      ) : (
        <Box color="average">
          No holding tank
        </Box>
      )}
    </Section>
  );
};
