import { BooleanLike } from "common/react";

export interface WirePanelData extends WirePanelProps, WirePanelTheme {} // Intake data
export interface WireProps extends WireStatic, WireDynamic {
  act: (action: string, payload: object) => void
  index: number
} // per-wire data
export interface IndicatorProps extends IndicatorsStatic, IndicatorsDynamic {}// per-indicator data

// Wire Panel Defintions. Sync with `_std/defines/obj.dm`

// Wire Panel Component: Wire Controls
export const WirePanelControls = {
  "WIRE_CONTROL_INERT": 0,
  "WIRE_CONTROL_GROUND": (1<<0),
  "WIRE_CONTROL_POWER_A": (1<<1),
  "WIRE_CONTROL_POWER_B": (1<<2),
  "WIRE_CONTROL_BACKUP_A": (1<<3),
  "WIRE_CONTROL_BACKUP_B": (1<<4),
  "WIRE_CONTROL_SILICON": (1<<5),
  "WIRE_CONTROL_ACCESS": (1<<6),
  "WIRE_CONTROL_SAFETY": (1<<7),
  "WIRE_CONTROL_RESTRICT": (1<<8),
  "WIRE_CONTROL_ACTIVATE": (1<<9),
  "WIRE_CONTROL_RECIEVE": (1<<10),
  "WIRE_CONTROL_TRANSMIT": (1<<11),
};

export const WirePanelControlLabels = {
  0: "Inert",
  1: "Ground",
  2: "Power",
  4: "Power Alt",
  8: "Backup",
  16: "Backup Alt",
  32: "AI Control",
  64: "ID Scanner",
  128: "Safety",
  256: "Restrictor",
  512: "Activation",
  1024: "Recieve Data",
  2048: "Transmit Data",
};


// Wire Panel Component: Wire Actions
export const WirePanelActions = {
  "WIRE_ACT_NONE": 0,
  "WIRE_ACT_CUT": (1<<0),
  "WIRE_ACT_MEND": (1<<1),
  "WIRE_ACT_PULSE": (1<<2),
};

// Wire Panel Component: Cover Status
export const WirePanelCoverStatus = {
  "WPANEL_COVER_OPEN": 0,
  "WPANEL_COVER_CLOSED": 1,
  "WPANEL_COVER_BROKEN": 2,
  "WPANEL_COVER_LOCKED": 3,
};

// Wire Panel Component: Indicator Pattern
export const WirePanelPatterns = {
  "WPANEL_PATTERN_ON": "on",
  "WPANEL_PATTERN_OFF": "off",
  "WPANEL_PATTERN_FLASHING": "flashing",
};

// Wire Panel Component: TGUI Wire Panel Themes
export const WirePaneThemes = {
  "WPANEL_THEME_CONTROLS": 0,
  "WPANEL_THEME_INDICATORS": 1,
};


export interface WirePanelProps {
  wirePanelDynamic: WirePanelDynamic
  wirePanelStatic: WirePanelStatic
}

interface WirePanelTheme {
  wirePanelTheme: number
}
interface WirePanelStatic {
wires: WireStatic[]
indicators: IndicatorsStatic[]
}

export interface WirePanelDynamic {
wires: WireDynamic[]
indicators: IndicatorsDynamic[]
cover_status: number
active_wire_controls: number
is_silicon_user: BooleanLike
is_accessing_remotely: BooleanLike
}

interface WireStatic {
  name: string
  value: string
}
interface WireDynamic {
  cut: BooleanLike
}

interface IndicatorsStatic {
  name: string
  value: string
  control: number
}
interface IndicatorsDynamic {
  pattern: string
  status: BooleanLike
}
