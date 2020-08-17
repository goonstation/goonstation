import { Box, AnimatedNumber } from '../../components';
import { formatTime } from '../../format';

export const DetonatorTimer = props => {
  const {
    time,
    warningThreshold = 30,
    dangerThreshold = 10,
    explosionMessage = "BO:OM",
  } = props;

  let timeColor = "green";
  if (time <= dangerThreshold) {
    timeColor = "red";
  } else if (time <= warningThreshold) {
    timeColor = "orange";
  }

  return (
    <Box
      p={1}
      textAlign="center"
      backgroundColor="black"
      color={timeColor}
      maxWidth="100px"
      fontSize="20px">
      <AnimatedNumber
        value={time}
        format={value => formatTime(value, explosionMessage)} />
    </Box>
  );
};
