// storage defines for storage datums and outside use

/// storage can hold the item
#define STORAGE_CAN_HOLD 1
/// storage can't hold the item, due to it being an unallowable type
#define STORAGE_CANT_HOLD 0
/// storage can't hold the item, due to it being too large
#define STORAGE_WONT_FIT -1
/// storage is restricted from holding the item, due to it being an explicitly restricted type
#define STORAGE_RESTRICTED_TYPE -2
/// storage can't hold the item, due to it being too full
#define STORAGE_IS_FULL -3
