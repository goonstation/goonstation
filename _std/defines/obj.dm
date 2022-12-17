
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

// Wire Panel Component: Wire Controls
/// Inert wire; no effect
#define WIRE_INERT_TODO 0
/// Wire to electrical ground
#define WIRE_GROUND_TODO	(1<<0)
/// Used alone, the sole power wire
#define WIRE_POWER_1_TODO	(1<<1)
/// Used if there is a second power wire
#define WIRE_POWER_2_TODO	(1<<2)
/// Used alone, the sole backup wire
#define WIRE_BACKUP_1_TODO	(1<<3)
/// Used if there is a second backup wire
#define WIRE_BACKUP_2_TODO	(1<<4)
/// Silicon wireless control enabled
#define WIRE_SILICON_TODO	(1<<5)
/// Access restrictions
#define WIRE_ACCESS_TODO	(1<<6)
/// Safety sensors
#define WIRE_SAFETY_TODO	(1<<7)
/// Enforces some limit
#define WIRE_RESTRICT_TODO	(1<<8)
/// Activate the thing
#define WIRE_ACTIVATE_TODO	(1<<9)
/// Recieve data
#define WIRE_RECIEVE_TODO	(1<<10)
/// Transmit data
#define WIRE_TRANSMIT_TODO	(1<<11)

// Wire Panel Component: Cover Status
/// Cover is open and you can access wires
#define PANEL_COVER_OPEN	0
/// Cover closed; default state
#define PANEL_COVER_CLOSED	1
/// Cover is broken; requires repair before opening
#define PANEL_COVER_BROKEN	2
/// Cover is locked; requires unlocking before opening
#define PANEL_COVER_LOCKED	3

#define WIRE_ACT_NONE (1<<0)
#define WIRE_ACT_CUT (1<<1)
#define WIRE_ACT_MEND (1<<2)
#define WIRE_ACT_PULSE (1<<3)

/*
Vending Machine - 4 wires - `vending.dm`
//	#define WIRE_EXTEND 1
//	#define WIRE_SCANID 2
//	#define WIRE_SHOCK 3
//	#define WIRE_SHOOTINV 4
WIRE_RESTRICT_TODO // WIRE_EXTEND
WIRE_ACCESS_TODO | WIRE_SILICON_TODO // WIRE_SCANID // this does two things, which we can handle!
WIRE_GROUND_TODO //  WIRE_SHOCK
WIRE_SAFETY_TODO //  WIRE_SHOOTINV
*/

/*
Weapon Racks - 4 wires - `weapon_racks.dm`
// 	WIRE_EXTEND = 1
//	WIRE_MALF = 2
//	WIRE_POWER = 3
//	WIRE_INERT = 4
WIRE_ACCESS_TODO  // WIRE_EXTEND
WIRE_GROUND_TODO // WIRE_MALF
WIRE_POWER_1_TODO // WIRE_POWER
WIRE_INERT_TODO // WIRE_INERT
*/

/*
APCs - 4 wires - `apc.dm`
//	#define APC_WIRE_IDSCAN 1
//	#define APC_WIRE_MAIN_POWER1 2
//	#define APC_WIRE_MAIN_POWER2 3
//	#define APC_WIRE_AI_CONTROL 4
WIRE_ACCESS_TODO // APC_WIRE_IDSCAN
WIRE_POWER_1_TODO // APC_WIRE_MAIN_POWER1
WIRE_POWER_2_TODO // APC_WIRE_MAIN_POWER2
WIRE_SILICON_TODO // APC_WIRE_AI_CONTROL
*/

/*
Mulebots - 10 wires - `mulebot.dm`
//	wire_power1 = 1			// power connections
//	wire_power2 = 2
//	wire_mobavoid = 4		// mob avoidance
//	wire_loadcheck = 8		// load checking (non-crate)
//	wire_motor1 = 16		// motor wires
//	wire_motor2 = 32		//
//	wire_remote_rx = 64		// remote recv functions
//	wire_remote_tx = 128	// remote trans status
//	wire_beacon_rx = 256	// beacon ping recv
//	wire_beacon_tx = 512	// beacon ping trans
WIRE_POWER_1_TODO // wire_power1
WIRE_POWER_2_TODO // wire_power2
WIRE_SAFETY_TODO // wire_mobavoid
WIRE_RESTRICT_TODO // wire_loadcheck // still used for auto-pickup vOv
WIRE_BACKUP_1_TODO // wire_motor1
WIRE_BACKUP_2_TODO // wire_motor2
WIRE_ACTIVATE_TODD // wire_remote_rx // can we recieve PDA signals
WIRE_ACCESS_TODO // wire_remote_tx // send data to PDAs
WIRE_RECIEVE_TODO // wire_beacon_rx // can we receive data from beacons
WIRE_TRANSMIT_TODO // wire_beacon_tx // transmit data to beacons
*/

/*
Detonator - detonator.dm - 6 wires (active)
//	WireFuncs = list("detonate", "defuse", "safety", "losetime", "mobility", "leak")
// 	// I think it adds multiple WIRE_INERT_TODO, which we can handle!
WIRE_ACTIVATE_TODO // "detonate"
WIRE_POWER_1_TODO // "defuse"
WIRE_SAFETY_TODO // "safety"
WIRE_BACKUP_1_TODO // "losetime"
WIRE_GROUND_TODO // "mobility" // haha get it?
WIRE__TODO // "leak" // "valve sensor unit goes dim and the canister starts leaking!"
*/

/*
Radio - radio.dm - 3 wires
//	WIRE_SIGNAL = 1 //sends a signal, like to set off a bomb or electrocute someone
//	WIRE_RECEIVE = 2
//	WIRE_TRANSMIT = 4
WIRE_ACTIVATE_TODD // WIRE_SIGNAL
WIRE_RECIEVE_TODO // WIRE_RECIEVE
WIRE_TRANSMIT_TODO  // WIRE_TRANSMIT
*/

/*
Seed vendor - `seed.dm` - 4 wires
// 	WIRE_EXTEND = 1
//	WIRE_MALF = 2
//	WIRE_POWER = 3
//	WIRE_INERT = 4
WIRE_RESTRICT_TODO // WIRE_EXTEND
WIRE_GROUND_TODO // WIRE_MALF
WIRE_POWER_1_TODO // WIRE_POWER
WIRE_INERT_TODO // WIRE_INERT
*/
