import { Box, TimeDisplay } from 'tgui-core/components';

import { formatTime } from '../../format';

export const DetonatorTimer = (props) => {
  const {
    time,
    isPrimed,
    warningThreshold = 300,
    dangerThreshold = 100,
    explosionMessage = 'BO:OM',
  } = props;

  let timeColor = 'green';
  if (time <= dangerThreshold) {
    timeColor = 'red';
  } else if (time <= warningThreshold) {
    timeColor = 'orange';
  }

  return (
    <Box
      p={1}
      textAlign="center"
      backgroundColor="black"
      color={timeColor}
      maxWidth="90px"
      width="90px"
      fontSize="20px"
    >
      <TimeDisplay
        value={time}
        auto={isPrimed ? 'down' : undefined}
        format={(value: number) => formatTime(value, explosionMessage)}
      />
    </Box>
  );
};
