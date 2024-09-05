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
