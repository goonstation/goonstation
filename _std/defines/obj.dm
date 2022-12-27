
// ---- object_flags ----

/// bot considers this solid object that can be opened with a bump() in pathfinding DirBlockedWithAccess
#define BOTS_DIRBLOCK 			 (1<<0)
/// illegal for arm attaching
#define NO_ARM_ATTACH 			 (1<<1)
/// access gun can reprog
#define CAN_REPROGRAM_ACCESS (1<<2)
/// this object only blocks things in certain directions, e.g. railings, thindows
#define HAS_DIRECTIONAL_BLOCKING (1<<3)
/// prevents ghost critter interaction. On obj so it can cover machinery, items etc...
#define NO_GHOSTCRITTER (1<<4)

/// At which alpha do opague objects become see-through?
#define MATERIAL_ALPHA_OPACITY 190

// ---- wire_panel ----

// Wire Panel Defintions. Sync with `tgui/packages/tgui/interfaces/common/WirePanel/type.ts`.

// Wire Panel Component: Wire Controls
/// Inert wire; no effect
#define WIRE_CONTROL_INERT	0
/// Wire to electrical ground
#define WIRE_CONTROL_GROUND	(1<<0)
/// Used alone, the sole power wire
#define WIRE_CONTROL_POWER_A	(1<<1)
/// Used if there is a second power wire
#define WIRE_CONTROL_POWER_B	(1<<2)
/// Used alone, the sole backup wire
#define WIRE_CONTROL_BACKUP_A	(1<<3)
/// Used if there is a second backup wire
#define WIRE_CONTROL_BACKUP_B	(1<<4)
/// Silicon wireless control enabled
#define WIRE_CONTROL_SILICON	(1<<5)
/// Access restrictions
#define WIRE_CONTROL_ACCESS	(1<<6)
/// Safety sensors
#define WIRE_CONTROL_SAFETY	(1<<7)
/// Enforces some limit
#define WIRE_CONTROL_RESTRICT	(1<<8)
/// Activate the thing
#define WIRE_CONTROL_ACTIVATE	(1<<9)
/// Recieve data
#define WIRE_CONTROL_RECIEVE	(1<<10)
/// Transmit data
#define WIRE_CONTROL_TRANSMIT	(1<<11)

// Wire Panel Component: Wire Actions
/// No action
#define WIRE_ACT_NONE	0
/// Wire is cut
#define WIRE_ACT_CUT	(1<<0)
/// Wire is mended
#define WIRE_ACT_MEND	(1<<1)
/// Wire is pulsed
#define WIRE_ACT_PULSE	(1<<2)

// Wire Panel Component: Cover Status
/// Cover is open and you can access wires
#define WPANEL_COVER_OPEN	0
/// Cover closed; default state
#define WPANEL_COVER_CLOSED	1
/// Cover is broken; requires repair before opening
#define WPANEL_COVER_BROKEN	2
/// Cover is locked; requires unlocking before opening
#define WPANEL_COVER_LOCKED	3

// Wire Panel Component: TGUI Wire Panel Settings
/// Text-based wire listing, with
#define WPANEL_THEME_TEXT 0
/// Skeuomorphic physical wires
#define WPANEL_THEME_PHYSICAL 1

/// Control Labels
#define WPANEL_THEME_CONTROLS	0
/// Indicator lights
#define WPANEL_THEME_INDICATORS	1
/// Exactly like Airlocks
#define WPANEL_THEME_AIRLOCK 2

// Wire Panel Component: Indicator Pattern
#define WPANEL_PATTERN_ON "on"
#define WPANEL_PATTERN_OFF "off"
#define WPANEL_PATTERN_FLASHING "flashing"
