/**
 * @file
 * @copyright 2022
 * @author CodeJester (https://github.com/codeJester27)
 * @license ISC
 */

import { Color } from 'common/color';

export const TemperatureColors = {
  cold: new Color(66, 194, 255),
  neutral: new Color(170, 170, 170),
  hot: new Color(255, 120, 0),
  veryhot: new Color(255, 0, 0),
};

export const freezeTemperature = 273.15;
export const neutralTemperature = 293.15;
const deviation = 200;
const highTemperature = neutralTemperature + deviation;

export const getTemperatureColor = (temperature, veryHighTemperature=1000) => {
  const { cold, neutral, hot, veryhot } = TemperatureColors;

  if (temperature < highTemperature) {
    return Color.lookup((temperature - neutralTemperature) / (deviation * 2) + 0.5, [cold, neutral, hot]);
  }
  return Color.lookup((temperature - highTemperature) / (veryHighTemperature - highTemperature), [hot, veryhot]);
};

export const getTemperatureIcon = (temperature) => {
  switch (Math.round(temperature/200)) {
    case (0): return "thermometer-empty";
    case (1): return "thermometer-quarter";
    case (2): return "thermometer-half";
    case (3): return "thermometer-three-quarters";
    default: return "thermometer-full";
  }
};

export const getTemperatureChangeName = (temperature, targetTemperature) => {
  if (temperature < targetTemperature) return "heating";
  if (temperature > targetTemperature) return "cooling";
  return "neutral";
};
