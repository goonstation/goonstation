/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { Button } from "../Button";
import { Image } from "../Image";
import { CenteredText } from "./CenteredText";

type ButtonWithBadgeProps = {
  width?: number,
  height?: number,
  noImageShadow?: boolean,
  image_path: string;
  text?: string;
  onClick?: Function;
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
  } = props;
  return (
    <Button
      onClick={onClick}
      ellipsis
      width={width} height={height}
      pl={0} pb={0}
      m={1}
    >
      <Image
        verticalAlign="top"
        height={5}
        pixelated
        src={image_path}
        backgroundColor={noImageShadow ? null : "rgba(0,0,0,0.2)"}
      />
      <CenteredText width={7} height={5} text={text} />
    </Button>
  );
};
