/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

/**
 * Controls the size and spacing of blueprint buttons on the main panel.
 */
export enum BlueprintButtonStyle {
  Width = 15.5,
  Height = 5,
  MarginX = 0.5,
  MarginY = 0.5,
}

// Controls the smaller 'settings' and 'info' buttons on the side of each larger button.
export enum BlueprintMiniButtonStyle {
  Width = 2,
  IconSize = 1,
  Spacing = 0.4,
}

export enum ProductionCardStyle {
  
}

// Controls the amount of space the blueprint window takes up. The remaining percentage is settings.
export const BLUEPRINT_WINDOW_WIDTH = "55%";

// Controls the width of buttons on the panel to be constant, so that cut/mend are of equal widths
export const WIRE_PANEL_BUTTONS_WIDTH = 5;

// Manudrives use a non-infinite value to specify there is unlimited uses, improve clarity for now
export const MANUDRIVE_UNLIMITED = -1;
