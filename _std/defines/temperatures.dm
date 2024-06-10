/// 0 degrees celsius. Freezing point of liquid water.
#define T0C 273.15
/// 20 degrees celsius. Room temperature.
#define T20C 293.15
/// -270.3 degrees celsius. Temperature of cosmic background radiation.
#define TCMB 2.7 KELVIN
/// 100 degrees celsius. Boiling point of liquid water.
#define T100C 373.15 KELVIN
/// 0 degrees fahrenheit.
#define T0F 459.67 KELVIN

/// 48 degrees celsius. Not super realistic, but there's underwater hot vents!
#define OCEAN_TEMP 321.15
/// 0.85 degrees celsius. Right above the freezing point of liquid water.
#define TRENCH_TEMP 274

/// Converts a temperature in kelvin to celsius.
#define TO_CELSIUS(K) ((K) - T0C)
/// Converts a temperature in kelvin to fahrenheit.
#define TO_FAHRENHEIT(K) (((K) - T0C) * 1.8 + 32)
/// Converts a temperature in celsius to kelvin.
#define FROM_CELSIUS(C) ((C) + T0C)
/// Converts a temperature in fahrenheit to kelvin.
#define FROM_FAHRENHEIT(F) (((F) - 32) / 1.8 + T0C)
