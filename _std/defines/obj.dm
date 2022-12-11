
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

// Machinery Wire Hacking - different things wires can do
#define WIRE_INERT 1 //! Inert wire; does nothing
#define WIRE_POWER_A 2 //! primary power wire
#define WIRE_POWER_B 4 //! Airlock - secondary power
#define WIRE_BACKUP_POWER_A 8 //! Airlock - backup power
#define WIRE_BACKUP_POWER_B 16 //! Airlock - secondary backup power
#define WIRE_CAN_SHOCK 32 //! Can shock users // TODO: rename to WIRE_SHOCK after integration
#define WIRE_ID_SCAN 64 //! Remove ID restrictions
#define WIRE_BOLTS 128 //! Airlock - door bolts
#define WIRE_SAFETY 256 //! Airlock - safety (crush) sensor
#define WIRE_EXTEND_INVENTORY 512 //! Has extended inventory selection
#define WIRE_MALFUNCTION 1024 //! Is malfunctining - how depends on machine
#define WIRE_SILICON_CONTROL 2048 //! Can silicons control it
