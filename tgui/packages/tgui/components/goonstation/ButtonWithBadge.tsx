/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { Stack } from "../Stack";
import { Button } from "../Button";
import { Image } from "../Image";
import { InfernoNode } from "inferno";
import { BooleanLike } from "common/react";

type ButtonWithBadgeProps = {
  width: number | string,
  height: number | string,
  noImageShadow?: BooleanLike,
  image_path: string;
  children?: InfernoNode;
  disabled?: BooleanLike;
  onClick?: Function;
  onMouseEnter?: Function;
  onMouseLeave?: Function;
  opacity?: number;
}

export const ButtonWithBadge = (props:ButtonWithBadgeProps) => {
  const {
    width,
    height,
    noImageShadow,
    image_path,
    children,
    onClick,
    onMouseEnter,
    onMouseLeave,
    opacity,
    disabled,
  } = props;

  return (
    <Button
      opacity={opacity}
      onClick={onClick}
      width={width} height={height}
      p={0}
      onMouseEnter={onMouseEnter}
      onMouseLeave={onMouseLeave}
      disabled={disabled}
    >
      <Stack>
        <Stack.Item>
          <Image
            verticalAlign="top"
            height={height}
            pixelated
            src={image_path}
            backgroundColor={noImageShadow ? null : "rgba(0,0,0,0.2)"}
          />
        </Stack.Item>
        <Stack.Item grow mx={1}>
          {children}
        </Stack.Item>
      </Stack>
    </Button>
  );
};
