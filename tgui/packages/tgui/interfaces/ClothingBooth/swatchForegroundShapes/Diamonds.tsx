/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { SwatchForegroundProps } from '../type';

export const SwatchDiamond = (props: SwatchForegroundProps) => {
  return (
    <svg
      width="auto"
      height="100%"
      fill={props.color}
      viewBox="0 0 6 6"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        transform="matrix(.64018 .76822 -.64018 .76822 -22.577782 0)"
        d="M20.297247-19.378817h2.7552822v2.7552826H20.297247z"
      />
      <path
        d="M25.016985 2.4392049h.76603258v.76603401H25.016985z"
        transform="translate(-22.577782)"
      />
    </svg>
  );
};
