
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
#define WIRE_CONTROL_INERT		0
/// Wire to electrical ground
#define WIRE_CONTROL_GROUND		(1<<0)
/// Half of power control
#define WIRE_CONTROL_POWER_A	(1<<1)
/// Other half of power
#define WIRE_CONTROL_POWER_B	(1<<2)
/// Both power controls
#define WIRE_CONTROL_POWER		WIRE_CONTROL_POWER_A | WIRE_CONTROL_POWER_B
/// Half of backup control
#define WIRE_CONTROL_BACKUP_A	(1<<3)
/// Other half of backup
#define WIRE_CONTROL_BACKUP_B	(1<<4)
/// Both backup controls
#define WIRE_CONTROL_BACKUP		WIRE_CONTROL_BACKUP_A | WIRE_CONTROL_BACKUP_B
/// Silicon wireless
#define WIRE_CONTROL_SILICON	(1<<5)
/// Access restrictions
#define WIRE_CONTROL_ACCESS		(1<<6)
/// Safety sensors
#define WIRE_CONTROL_SAFETY		(1<<7)
/// Enforce some limit
#define WIRE_CONTROL_LIMITER	(1<<8)
/// Activate some trigger
#define WIRE_CONTROL_TRIGGER	(1<<9)
/// Recieve data
#define WIRE_CONTROL_RECEIVE	(1<<10)
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
/// Wire is cut or pulsed
#define WIRE_ACT_CUT_PULSE WIRE_ACT_CUT | WIRE_ACT_PULSE
/// Wire is mended or pulsed
#define WIRE_ACT_MEND_PULSE  WIRE_ACT_MEND | WIRE_ACT_PULSE

// Wire Panel Component: Cover Status
/// Cover is open and you can access wires
#define WPANEL_COVER_OPEN	0
/// Cover closed; default state
#define WPANEL_COVER_CLOSED	1
/// Cover is broken; requires repair before opening
#define WPANEL_COVER_BROKEN	2
/// Cover is locked; requires unlocking before opening
#define WPANEL_COVER_LOCKED	3
