/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { Stack } from "../../../components/Stack";
import { Button } from "../../../components/Button";
import { Image } from "../../../components/Image";
import { InfernoNode } from "inferno";

type ButtonWithBadgeProps = {
  width?: number | string,
  height?: number | string,
  noImageShadow?: boolean,
  imagePath: string | null;
  children?: InfernoNode;
  disabled?: boolean;
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
    imagePath,
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
      width={width || "100%"}
      height={height || "100%"}
      p={0}
      onMouseEnter={onMouseEnter}
      onMouseLeave={onMouseLeave}
      disabled={disabled}
    >
      <Stack>
        <Stack.Item>
          {imagePath && (
            <Image
              verticalAlign="top"
              height={height || "100%"}
              src={imagePath}
              backgroundColor={noImageShadow ? null : "rgba(0,0,0,0.2)"}
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
