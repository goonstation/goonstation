import { Box, Button } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { DiskButtonProps } from './types';

export const DiskButton = (props: DiskButtonProps) => {
  const { index, diskName, diskColor, ...rest } = props;
  const { act } = useBackend();
  return (
    <Button
      width="25em"
      key={props.index}
      onClick={() => act('diskAction', { id: index ? index + 1 : 1 })}
      icon={'eject'}
      iconPosition="left"
      textColor={diskName ? 'black' : 'white'}
      tooltip={diskName}
      style={{
        cursor: 'grab',
      }}
      backgroundColor={diskColor}
    >
      {!!diskName && (
        <Box
          width="21em"
          inline
          backgroundColor="white"
          pt="3px"
          pl="4px"
          height="25px"
          mb="-3px"
          bold
          textAlign="center"
          style={{
            borderColor: '#cccccc',
            borderWidth: '3px',
            borderStyle: 'ridge',
            borderTop: 'none',
            borderRadius: '10px',
            borderTopLeftRadius: '0px',
            borderTopRightRadius: '0px',
            overflow: 'hidden',
            textOverflow: 'ellipsis',
          }}
        >
          {diskName}
        </Box>
      )}
      {!diskName && (
        <Box inline height="27px" pt="3px">
          Empty slot
        </Box>
      )}
    </Button>
  );
};
