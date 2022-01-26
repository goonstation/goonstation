import { classes } from "common/react";
import { Box } from "./Box";

export const Image = (props) => {
  const { pixelated, className, ...rest } = props;

  return (<Box as="img" {...rest} className={classes(
    "Image",
    pixelated && "Image--pixelated",
    className
  )} />);
};
