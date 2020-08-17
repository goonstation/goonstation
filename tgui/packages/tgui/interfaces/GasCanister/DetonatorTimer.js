import { Box, AnimatedNumber } from '../../components';
import { formatTime } from '../../format';

export const DetonatorTimer = props => {
  const {
    time,
    warningThreshold = 30,
    dangerThreshold = 10,
    explosionMessage = "BO:OM",
  } = props;

  const timeColor = () => {
    if (time <= dangerThreshold) {
      return "red";
    } else if (time <= warningThreshold) {
      return "orange";
    } else {
      return "green";
    }
  };

  return (
    <Box
      p={1}
      textAlign="center"
      backgroundColor="black"
      color={timeColor()}
      maxWidth="100px"
      fontSize="20px">
      <AnimatedNumber
        value={time}
        format={value => formatTime(value, explosionMessage)} />
    </Box>
  );
};
