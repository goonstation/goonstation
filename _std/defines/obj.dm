
// ---- object_flags ----

/// bot considers this solid object that can be opened with a Bump() in pathfinding DirBlockedWithAccess
#define BOTS_DIRBLOCK 			 (1<<0)
/// illegal for arm attaching
#define NO_ARM_ATTACH 			 (1<<1)
/// access gun can reprog
#define CAN_REPROGRAM_ACCESS (1<<2)
/// Overrides multicontext menu popup when an object is clicked by a player who is holding an item
#define IGNORE_CONTEXT_CLICK_HELD (1<<3)

/// At which alpha do opague objects become see-through?
#define MATERIAL_ALPHA_OPACITY 190
