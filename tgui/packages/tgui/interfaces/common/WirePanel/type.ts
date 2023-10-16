/**
 * @file
 * @copyright 2023
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { BooleanLike } from "common/react";

export interface WirePanelData {
  wire_panel: {
    cover_status: number
    hacked_controls: number
    control_lights: number
    is_silicon_user: BooleanLike
    is_accessing_remotely: BooleanLike
    wires: WireData[]
  }
}

export interface WireData {
  color_name: string
  color_value: string
  is_cut: BooleanLike
}
