import { SwatchForegroundProps } from "../type";

export const SwatchBisectRight = (props: SwatchForegroundProps) => {
  return (
    <svg width="100%" fill={props.color} viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
      <path d="m64 64 l-64 0 l64 -64 z" />
    </svg>
  );
};
