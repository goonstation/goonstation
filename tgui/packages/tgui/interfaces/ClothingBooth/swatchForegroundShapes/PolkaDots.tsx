/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { SwatchForegroundProps } from '../type';

export const SwatchPolkaDots = (props: SwatchForegroundProps) => {
  return (
    <svg
      fill={props.color}
      xmlns="http://www.w3.org/2000/svg"
      xmlnsXlink="http://www.w3.org/1999/xlink"
      width="100%"
      height="100%"
      viewBox="0 0 5.6444439 5.6444445"
    >
      <defs>
        <pattern
          xlinkHref="#a"
          id="b"
          x="-16"
          y="-16"
          patternTransform="scale(.2)"
          preserveAspectRatio="xMidYMid"
        />
        <pattern
          id="a"
          width="10"
          height="10"
          x="0"
          y="0"
          fill="#000"
          patternUnits="userSpaceOnUse"
          preserveAspectRatio="xMidYMid"
        >
          <g paint-order="markers fill stroke" transform="scale(.1)">
            <circle cx="50" cy="50" r="25" />
            <path d="M25 0A25 25 0 0 1 0 25 25 25 0 0 1-25 0 25 25 0 0 1 0-25 25 25 0 0 1 25 0Zm100 0a25 25 0 0 1-25 25A25 25 0 0 1 75 0a25 25 0 0 1 25-25 25 25 0 0 1 25 25ZM25 100a25 25 0 0 1-25 25 25 25 0 0 1-25-25A25 25 0 0 1 0 75a25 25 0 0 1 25 25Zm100 0a25 25 0 0 1-25 25 25 25 0 0 1-25-25 25 25 0 0 1 25-25 25 25 0 0 1 25 25z" />
          </g>
        </pattern>
      </defs>
      <path
        fill="url(#b)"
        d="M11.288889 4e-7h5.6444445v5.6444445H11.288889z"
        transform="translate(-11.288889)"
      />
    </svg>
  );
};
