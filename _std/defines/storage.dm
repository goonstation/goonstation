// storage defines for storage datums and outside use

/// storage can hold the item
#define STORAGE_CAN_HOLD 2
/// there is room for some of the item, but not all
#define STORAGE_CAN_HOLD_SOME 1
/// storage can't hold the item, due to it being an unallowable type
#define STORAGE_CANT_HOLD 0
/// storage can't hold the item, due to it being too large
#define STORAGE_WONT_FIT -1
/// storage is restricted from holding the item, due to it being an explicitly restricted type
#define STORAGE_RESTRICTED_TYPE -2
/// storage can't hold the item, due to it being too full
#define STORAGE_IS_FULL -3

// no_hud storage defines

/// items are stored in queue order
#define STORAGE_NO_HUD_QUEUE 0
/// items are stored in stack order
#define STORAGE_NO_HUD_STACK 1
/// items pulled out are random picked
#define STORAGE_NO_HUD_RANDOM 2

// check_wclass behaviour defines

/// Default behavior; changes based on the `list/can_hold` variable.
///
///If `can_hold` is defined, store items if in `can_hold`, regardless of `max_wclass`. 
///
///If `can_hold` is empty/undefined, store items equal or under `max_wclass`.
#define STORAGE_CHECK_W_CLASS_IGNORE 0
/// Store items in `can_hold` OR items equal or under `max_wclass`.
#define STORAGE_CHECK_W_CLASS_INCLUDE 1
/// Store items that are in the `can_allow` list AND equal or under `max_wclass`.
#define STORAGE_CHECK_W_CLASS_EXCLUDE 2
