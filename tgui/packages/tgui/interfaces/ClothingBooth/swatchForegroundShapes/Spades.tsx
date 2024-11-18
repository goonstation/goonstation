/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { SwatchForegroundProps } from '../type';

export const SwatchSpade = (props: SwatchForegroundProps) => {
  return (
    <svg
      width="auto"
      height="100%"
      fill={props.color}
      viewBox="0 0 6 6"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="M7.1516194 26.160332a1.0171414.92993586 89.999977 0 1-.0002404-1.438369l1.3152876-1.43863 1.315048 1.438368a.92993586 1.0171414.000022 0 1 0 1.438631.92993586 1.0171414.000022 0 1-1.3152885-.000001 1.0171414.92993586 89.999977 0 1-1.3148067.000001z"
        transform="translate(-5.644446 -22.577778)"
      />
      <path
        d="M6.2057433 21.212796H5.0721211l.5668111-.981745z"
        transform="matrix(1.43735 0 0 1.07801 -5.28289281 -17.9287561)"
      />
      <path
        d="M36.305872 2.4392049h.766033v.7660341h-.766033z"
        transform="translate(-33.866669)"
      />
    </svg>
  );
};
