/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { SwatchForegroundProps } from '../type';

export const SwatchHearts = (props: SwatchForegroundProps) => {
  return (
    <svg
      width="auto"
      height="100%"
      fill={props.color}
      viewBox="0 0 6 6"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="M18.002159 1.1028902a1.2399147 1.3561888.00002262 0 0-.000321 1.917825l1.753718 1.918174 1.753397-1.917823a1.3561888 1.2399147 89.999978 0 0 0-1.918176 1.3561888 1.2399147 89.999978 0 0-1.753718.000001 1.2399147 1.3561888.00002262 0 0-1.753076-.000001z"
        transform="translate(-16.933334)"
      />
      <path
        d="M19.37254 2.4392052h.76603258v.76603401H19.37254z"
        transform="translate(-16.933334)"
      />
    </svg>
  );
};
