/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { Box } from "../Box";

type CenteredTextProps = {
  width:number | string,
  height:number | string,
  text:string;
}

export const CenteredText = (props:CenteredTextProps) => {
  // Strongly encouraged if you're reading this due to dissatisfaction with customizability that you implement
  // your desired feature so you and others can use it <3
  const {
    width,
    height,
    text,
  } = props;
  return (
    <Box
      preserveWhitespace
      inline
      width={width} height={height} lineHeight={height}
      style={{ "text-align": "center" }}
      px={0.5} // comfort padding
    >
      <span
        style={{
          "display": "inline-block",
          "vertical-align": "middle",
          "line-height": "normal",
        }}>
        {text}
      </span>
    </Box>
  );
};

