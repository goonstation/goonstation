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

/// Standard for any storage with list/can_hold defined. Only what is in that list can be held in the storage, independing of w_class
#define STORAGE_CHECK_W_CLASS_IGNORE 0
/// Above list/can_hold, everything which is within the wclass defined in max_wclass can fit in the storage as well
#define STORAGE_CHECK_W_CLASS_INCLUDE 1
/// Causes the storage not not allow things in list/can_hold which have a wclass higher than what is defined in max_wclass
#define STORAGE_CHECK_W_CLASS_EXCLUDE 2
