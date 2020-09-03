import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Section, AnimatedNumber } from '../components';
import { Window } from '../layouts';
import { PressureBar } from './common/PressureBar';
import { ReleaseValve } from './common/ReleaseValve';

export const GasTank = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    pressure,
    maxPressure,
    valveIsOpen,
    releasePressure,
    maxRelease,
  } = data;

  const handleSetPressure = releasePressure => {
    act('set-pressure', {
      releasePressure,
    });
  };

  const handleToggleValve = () => {
    act('toggle-valve');
  };

  return (
    <Window
      width={400}
      height={220}>
      <Window.Content>
        <Section
          title="Status">
          <GasTankInfo
            pressure={pressure}
            maxPressure={maxPressure} />
        </Section>
        <Section>
          <ReleaseValve
            valveIsOpen={valveIsOpen}
            releasePressure={releasePressure}
            maxRelease={maxRelease}
            onToggleValve={handleToggleValve}
            onSetPressure={handleSetPressure} />
        </Section>
      </Window.Content>
    </Window>
  );

};

export const GasTankInfo = props => {
  const {
    pressure,
    maxPressure,
  } = props;

  return (
    <Fragment>
      <Box
        pb={1}>
        <Box
          inline
          color="label">
          Pressure:
        </Box>
        <Box
          inline
          mx={1}>
          <AnimatedNumber
            value={pressure} />
          {' kPa'}
        </Box>
      </Box>
      <Box
        maxWidth="400px">
        <PressureBar
          pressure={pressure}
          maxPressure={maxPressure} />
      </Box>
    </Fragment>
  );
};
