import { Box, ProgressBar, AnimatedNumber } from '../../components';



export const PressureBar = props => {
  const {
    pressure,
    max_pressure,
    ...rest
  } = props;

  const bgColorSafe = "black";
  const bgColorDanger = "red";
  const barColorSafe = "green";
  const barColorDanger = "yellow";

  const barColor = () => {
    if ((pressure / max_pressure) > 1) {
      return barColorDanger;
    } else {
      return barColorSafe;
    }
  };

  const bgColor = () => {
    if ((pressure / max_pressure) > 1) {
      return bgColorDanger;
    } else {
      return bgColorSafe;
    }
  };

  const pct = () => {
    if (pressure / max_pressure > 1) {
      return pressure / (max_pressure * 10);
    } else {
      return pressure / max_pressure;
    }
  };

  return (
    <Box danger p={0.5} backgroundColor={bgColor()}>
      <ProgressBar color={barColor()} value={pct()}>
        <AnimatedNumber
          value={pressure}
          format={value => (Math.floor(value * 100) / 100) + " kPa"}
        />
      </ProgressBar>
    </Box>
  );
};
