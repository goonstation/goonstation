/**
 * @file
 * @copyright 2026
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

export interface DriveSlotProps {
  onClick?: () => void;
}

export interface DriveBaseProps {
  // if not provided, behavior will default to onEject/onInsert based on whether has content or not
  onContentClick?: () => void;
  onEject: () => void;
  onInsert: () => void;
}
