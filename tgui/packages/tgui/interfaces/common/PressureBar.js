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


  const barColor = (
    (pressure / maxPressure) > 1
      ? barColorDanger
      : barColorSafe
  );
  const bgColor = (
    (pressure / maxPressure) > 1
      ? bgColorDanger
      : bgColorSafe
  );
  const pct = (
    (pressure / maxPressure) > 1
      ? pressure / (maxPressure * 10)
      : pressure / maxPressure
  );

  return (
    <Box
      danger
      p={0.5}
      backgroundColor={bgColor}>
      <ProgressBar
        className="port-atmos-pressure-bar__text"
        color={barColor}
        value={pct}>
        <AnimatedNumber
          value={pressure}
          format={value => (Math.floor(value * 100) / 100) + " kPa"}
        />
      </ProgressBar>
    </Box>
  );
};
