/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { Stack } from "../Stack";
import { Button } from "../Button";
import { Image } from "../Image";
import { CenteredText } from "./CenteredText";

type ButtonWithBadgeProps = {
  width: number | string,
  height: number | string,
  noImageShadow?: boolean,
  image_path: string;
  text?: string;
  onClick?: Function;
  onMouseEnter?: Function;
  onMouseLeave?: Function;
  opacity?: number;
}

export const ButtonWithBadge = (props:ButtonWithBadgeProps) => {
  // Strongly encouraged if you're reading this due to dissatisfaction with customizability that you implement
  // your desired feature so you and others can use it <3
  const {
    width,
    height,
    noImageShadow,
    image_path,
    text,
    onClick,
    onMouseEnter,
    onMouseLeave,
    opacity,
  } = props;

  return (
    <Button
      opacity={opacity}
      onClick={onClick}
      width={width} height={height}
      p={0}
      onMouseEnter={onMouseEnter}
      onMouseLeave={onMouseLeave}
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
          <CenteredText height={height} text={text} />
        </Stack.Item>
      </Stack>
    </Button>
  );
};
