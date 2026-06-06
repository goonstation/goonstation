/**
 * @file
 * @copyright 2025
 * @author Garash (https://github.com/garash2k)
 * @license MIT
 */

// Controls the size and spacing of blueprint buttons on the main panel.
export enum ItemButtonStyle {
  Width = 15.5,
  Height = 5.333333333, // 64px @ 12px/unit
  MarginX = 0.5,
  MarginY = 0.5,
  Display = 'inline-flex',
}

// Controls the smaller 'settings' and 'info' buttons on the side of each larger button.
export enum ItemButtonMiniButtonStyle {
  Width = 2,
  IconSize = 1.2,
  Spacing = 0.5,
}
