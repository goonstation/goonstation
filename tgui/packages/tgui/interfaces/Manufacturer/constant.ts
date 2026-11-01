/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */

// Controls the amount of space the settings window takes up.
export const SETTINGS_WINDOW_WIDTH = 20;

// Controls the width of buttons on the panel to be constant, so that cut/mend are of equal widths
export const WIRE_PANEL_BUTTONS_WIDTH = 5;

// Manudrives use a non-infinite value to specify there is unlimited uses, improve clarity for now
export const MANUDRIVE_UNLIMITED = -1;

// Constants for the rockbox display, there needs to be a bit of custom defines to make it look decent
export enum RockboxStyle {
  MarginTop = 2,
}

// Constants for the representation obj proc "allowed" has in its return values of a response
export enum AccessLevels {
  DENIED = 0,
  IMPLICIT = 1,
  ALLOWED = 2,
}

// Controls the production card styling
export enum ProductionCardStyle {
  Width = SETTINGS_WINDOW_WIDTH,
  Height = 4,
  ButtonWidth = 2,
  ButtonInternalSpacing = 0.5,
}
