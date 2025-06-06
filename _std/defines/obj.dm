
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
/// allows for tables to be built under items they normally wouldn't be able to be built under, such as microwaves and personal computers
#define NO_BLOCK_TABLE (1<<5)

/// At which alpha do opague objects become see-through?
#define MATERIAL_ALPHA_OPACITY 190
