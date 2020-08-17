import { Box, ProgressBar, AnimatedNumber } from '../../components';

export const PressureBar = props => {
  const {
    pressure,
    maxPressure,
  } = props;

  const bgColorSafe = "black";
  const bgColorDanger = "red";
  const barColorSafe = "green";
  const barColorDanger = "yellow";

  const barColor = () => {
    if ((pressure / maxPressure) > 1) {
      return barColorDanger;
    } else {
      return barColorSafe;
    }
  };

  const bgColor = () => {
    if ((pressure / maxPressure) > 1) {
      return bgColorDanger;
    } else {
      return bgColorSafe;
    }
  };

  const pct = () => {
    if ((pressure / maxPressure) > 1) {
      return pressure / (maxPressure * 10);
    } else {
      return pressure / maxPressure;
    }
  };

  return (
    <Box
      danger p={0.5}
      backgroundColor={bgColor()}>
      <ProgressBar
        color={barColor()}
        value={pct()}>
        <AnimatedNumber
          value={pressure}
          format={value => (Math.floor(value * 100) / 100) + " kPa"}
        />
      </ProgressBar>
    </Box>
  );
};
