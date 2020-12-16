/**
 * @file
 * @copyright 2020 bobbahbrown (https://github.com/bobbahbrown)
 * @license MIT
 */

import { clamp01, keyOfMatchingRange, scale } from 'common/math';
import { classes } from 'common/react';
import { AnimatedNumber } from './AnimatedNumber';
import { Box, computeBoxClassName, computeBoxProps } from './Box';

export const RoundGauge = props => {
  // Support for IE8 is for losers sorry B)
  if (Byond.IS_LTE_IE8) {
    return (
      <AnimatedNumber {...props} />
    );
  }

  const {
    value,
    minValue = 1,
    maxValue = 1,
    ranges,
    alertAfter,
    format,
    size = 1,
    className,
    style,
    ...rest
  } = props;

  const scaledValue = scale(
    value,
    minValue,
    maxValue);
  const clampedValue = clamp01(scaledValue);
  let scaledRanges = ranges ? {} : { "primary": [0, 1] };
  if (ranges)
  { Object.keys(ranges).forEach(x => {
    const range = ranges[x];
    scaledRanges[x] = [
      scale(range[0], minValue, maxValue),
      scale(range[1], minValue, maxValue),
    ];
  }); }

  let alertColor = null;
  if (alertAfter < value) {
    alertColor = keyOfMatchingRange(clampedValue, scaledRanges);
  }

  return (
    <Box inline>
      <div
        className={classes([
          'RoundGauge',
          className,
          computeBoxClassName(rest),
        ])}
        {...computeBoxProps({
          style: {
            'font-size': size + 'em',
            ...style,
          },
          ...rest,
        })}>
        <svg
          viewBox="0 0 100 50">
          {alertAfter && (
            <g className={classes([
              'RoundGauge__alert',
              alertColor ? `active RoundGauge__alert--${alertColor}` : '',
            ])}>
              <Icon name="exclamation-triangle"/>
            </g>
          )}
          <g>
            <circle
              className="RoundGauge__ringTrack"
              cx="50"
              cy="50"
              r="45" />
          </g>
          <g>
            {Object.keys(scaledRanges).map((x, i) => {
              const col_ranges = scaledRanges[x];
              return (
                <circle
                  className={`RoundGauge__ringFill RoundGauge--color--${x}`}
                  key={i}
                  style={{
                    'stroke-dashoffset': (
                      Math.max((2.0 - (col_ranges[1] - col_ranges[0]))
                        * Math.PI * 50, 0)
                    ),
                  }}
                  transform={`rotate(${180 + 180 * col_ranges[0]} 50 50)`}
                  cx="50"
                  cy="50"
                  r="45" />
              );
            })}
          </g>
          <g
            className="RoundGauge__needle"
            transform={`rotate(${clampedValue * 180 - 90} 50 50)`}>
            <polygon
              className="RoundGauge__needleLine"
              points="46,50 50,0 54,50" />
            <circle
              className="RoundGauge__needleMiddle"
              cx="50"
              cy="50"
              r="8" />
          </g>
        </svg>
      </div>
      <AnimatedNumber
        value={value}
        format={format}
        size={size} />
    </Box>
  );
};
