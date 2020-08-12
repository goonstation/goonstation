import { Box, AnimatedNumber } from '../../components';

export const DetonatorTimer = props => {
  const {
    time,
    warningThreshold = 30,
    dangerThreshold = 10,
    explosionMessage = "BO:OM",
  } = props;

  const FormatTime = () => {
    let seconds = Math.floor(time % 60);
    let minutes = Math.floor((time - seconds) / 60);
    if (time <= 0) {
      return explosionMessage;
    }
    if (seconds < 10) {
      seconds = `0${seconds}`;
    }
    if (minutes < 10) {
      minutes = `0${minutes}`;
    }

    return `${minutes}:${seconds}`;
  };

  const TimeColor = () => {
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
      color={TimeColor()}
      maxWidth="100px"
      fontSize="19px">
      <AnimatedNumber
        value={time}
        format={() => FormatTime()} />
    </Box>
  );
};
