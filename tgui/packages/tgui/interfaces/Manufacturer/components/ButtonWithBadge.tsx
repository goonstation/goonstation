/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */

import { PropsWithChildren } from 'react';
import { Button, Stack } from 'tgui-core/components';

import { Image } from '../../../components/goonstation/Image';

interface ButtonWithBadgeProps {
  width?: number | string;
  height?: number | string;
  noImageShadow?: boolean;
  imagePath: string | null;
  disabled?: boolean;
  onClick?: (e: any) => void;
  opacity?: number;
}

export const ButtonWithBadge = (
  props: PropsWithChildren<ButtonWithBadgeProps>,
) => {
  const {
    width,
    height,
    noImageShadow,
    imagePath,
    children,
    onClick,
    opacity,
    disabled,
  } = props;

  return (
    <Button
      opacity={opacity}
      onClick={onClick}
      width={width || '100%'}
      height={height || '100%'}
      p={0}
      disabled={disabled}
    >
      <Stack>
        <Stack.Item>
          {imagePath && (
            <Image
              verticalAlign="top"
              height={height || '100%'}
              src={imagePath}
              backgroundColor={noImageShadow ? null : 'rgba(0,0,0,0.2)'}
            />
          )}
        </Stack.Item>
        <Stack.Item grow mx={1}>
          {children}
        </Stack.Item>
      </Stack>
    </Button>
  );
};
