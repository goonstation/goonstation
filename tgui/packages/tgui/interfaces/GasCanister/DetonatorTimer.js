import { Box, TimeDisplay } from '../../components';
import { formatTime } from '../../format';

export const DetonatorTimer = props => {
  const {
    time,
    isPrimed,
    warningThreshold = 300,
    dangerThreshold = 100,
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
      maxWidth="90px"
      width="90px"
      fontSize="20px">
      <TimeDisplay
        value={time}
        timing={isPrimed}
        format={value => formatTime(value, explosionMessage)} />
    </Box>
  );
};
