/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { SwatchForegroundProps } from '../type';

export const SwatchClub = (props: SwatchForegroundProps) => {
  return (
    <svg
      width="auto"
      height="100%"
      fill={props.color}
      viewBox="0 0 6 6"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="M8.4666668 17.638717a1.0583327 1.0583327 0 0 0-1.0583333 1.058333 1.0583327 1.0583327 0 0 0 .0640787.355017A1.0583327 1.0583327 0 0 0 7.4083335 19.05a1.0583327 1.0583327 0 0 0-1.0583334 1.058334 1.0583327 1.0583327 0 0 0 1.0583334 1.058333 1.0583327 1.0583327 0 0 0 1.0583333-1.058333 1.0583327 1.0583327 0 0 0 1.0583334 1.058333 1.0583327 1.0583327 0 0 0 1.0583338-1.058333A1.0583327 1.0583327 0 0 0 9.5250002 19.05a1.0583327 1.0583327 0 0 0-.065112.0047 1.0583327 1.0583327 0 0 0 .065112-.357601 1.0583327 1.0583327 0 0 0-1.0583334-1.058333Z"
        transform="translate(-5.644445 -16.933247)"
      />
      <path
        d="M6.2057433 21.212796H5.0721211l.5668111-.981745z"
        transform="matrix(1.43735 0 0 1.07801 -5.28289181 -17.92866948)"
      />
      <path
        d="M30.661428 2.4392056h.766033v.7660341h-.766033z"
        transform="translate(-28.222223)"
      />
    </svg>
  );
};
