/**
 * @file
 * @copyright 2025
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { PropsWithChildren, useContext } from 'react';
import { Box, Button } from 'tgui-core/components';

import { DiskDriveContext } from './context';

interface DiskProps {
  color: string;
  tooltip?: string;
}

export function Disk(props: PropsWithChildren<DiskProps>) {
  const { children, color, tooltip } = props;
  const { onDiskClick: onClick } = useContext(DiskDriveContext);
  const style = onClick ? { cursor: 'grab' } : undefined;
  return (
    <Button
      fluid
      onClick={onClick}
      style={style}
      tooltip={tooltip ?? (typeof children === 'string' ? children : undefined)}
      backgroundColor={color}
      align="center"
      height="100%"
    >
      {typeof children === 'string' ? (
        <Box
          backgroundColor="white"
          px={1}
          mx={2}
          bold
          textAlign="center"
          style={{
            borderColor: '#cccccc',
            borderWidth: '3px',
            borderStyle: 'ridge',
            borderTop: 'none',
            borderRadius: '10px',
            borderTopLeftRadius: '0',
            borderTopRightRadius: '0',
            overflow: 'hidden',
            textOverflow: 'ellipsis',
          }}
          textColor="black"
        >
          {children}
        </Box>
      ) : (
        children
      )}
    </Button>
  );
}
