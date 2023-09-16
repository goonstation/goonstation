import { BooleanLike } from "common/react";

export interface WirePanelData extends WirePanelProps {
  wirePanelTheme: WirePanelTheme
} // Intake data
export interface WireProps extends WireStatic, WireDynamic {
  act: (action: string, payload: object) => void
  index: number
} // per-wire data
export interface IndicatorProps extends IndicatorsStatic, IndicatorsDynamic {}// per-indicator data

// Wire Panel Definitions. Sync with `_std/defines/obj.dm`

export interface WirePanelProps {
  wirePanelDynamic: WirePanelDynamic
  wirePanelStatic: WirePanelStatic
}

export interface WirePanelTheme {
  wireTheme: number,
  controlTheme: number,
  windowTheme?: string,
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
