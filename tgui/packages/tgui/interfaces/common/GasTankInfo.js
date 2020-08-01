import { useBackend } from '../../backend';
import { Fragment } from 'inferno';
import { Box, Section, LabeledList, Button, AnimatedNumber } from '../../components';
import { PressureBar } from './PressureBar';

export const GasTankInfo = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    pressure,
    max_pressure,
  } = data;

  return (
    <Fragment>
      <Box pb="1em">
        <Box inline color="label">
          Pressure:
        </Box>
        <Box inline mx="1em">
          <AnimatedNumber
            value={pressure} />
          {' kPa'}
        </Box>
      </Box>
      <Box>
        <PressureBar pressure={pressure} max_pressure={max_pressure} />
      </Box>
    </Fragment>
  );
};
