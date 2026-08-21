export interface TurbineHistorySample {
  rpm: number;
  load: number;
  power: number;
  temperature: number;
  pressure: number;
  outletTemperature: number;
  outletPressure: number;
}

export interface TurbineBladeData {
  installed: boolean;
  healthPercent: number;
}

export interface TurbineStatorData {
  installed: boolean;
}

export interface TurbineControlData {
  connected: boolean;
  rpm: number;
  load: number;
  power: number;
  volume: number;
  volumeMax: number;
  history: TurbineHistorySample[];
  optimalRPM: number;
  overspeedRPM: number;
  statorLoadMin: number;
  statorLoadMax: number;
  flowRateMin: number;
  minimumTemperature: number;
  overtempWarning: number;
  overtempLimit: number;
  inletTemperature: number;
  inletPressure: number;
  outletTemperature: number;
  outletPressure: number;
  overspeed: boolean;
  overtemp: boolean;
  undertemp: boolean;
  stalling: boolean;
  ruined: boolean;
  blade: TurbineBladeData | null;
  stator: TurbineStatorData | null;
}
