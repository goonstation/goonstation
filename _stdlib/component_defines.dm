/// Used to trigger signals and call procs registered for that signal
/// The datum hosting the signal is automaticaly added as the first argument
/// Returns a bitfield gathered from all registered procs
/// Arguments given here are packaged in a list and given to _SendSignal
#define SEND_SIGNAL(target, sigtype, arguments...) ( !target.comp_lookup || !target.comp_lookup[sigtype] ? 0 : target._SendSignal(sigtype, list(target, ##arguments)) )

/// A wrapper for _AddComponent that allows us to pretend we're using normal named arguments
#define AddComponent(arguments...) _AddComponent(list(##arguments))


/// Return this from `/datum/component/Initialize` or `datum/component/OnTransfer` to have the component be deleted if it's applied to an incorrect type.
/// `parent` must not be modified if this is to be returned.
/// This will be noted in the runtime logs
#define COMPONENT_INCOMPATIBLE 1
/// Returned in PostTransfer to prevent transfer, similar to `COMPONENT_INCOMPATIBLE`
#define COMPONENT_NOTRANSFER 2

// How multiple components of the exact same type are handled in the same datum
/// old component is deleted (default)
#define COMPONENT_DUPE_HIGHLANDER		0
/// duplicates allowed
#define COMPONENT_DUPE_ALLOWED			1
/// new component is deleted
#define COMPONENT_DUPE_UNIQUE			2
/// old component is given the initialization args of the new
#define COMPONENT_DUPE_UNIQUE_PASSARGS	4
/// each component of the same type is consulted as to whether the duplicate should be allowed
#define COMPONENT_DUPE_SELECTIVE		5

// "so if a proc bound to a signal returns a value it's treated as bit flags" - Pali
/// Success
#define COMSIG_RETURN_SUCCESS 1
/// Failure
#define COMSIG_RETURN_FAILURE 2
/// return early (don't complete rest of proc)
#define COMSIG_RETURN_EARLY 4

// /datum signals
/// when a component is added to a datum: (/datum/component)
#define COMSIG_COMPONENT_ADDED "component_added"
/// before a component is removed from a datum because of RemoveComponent: (/datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"
/// just before a datum's disposing()
#define COMSIG_PARENT_PRE_DISPOSING "parent_pre_disposing"

// atom signals
/// When an atom is attacked by an item by a mob
#define COMSIG_ATOM_ATTACK_BY "atom_attack_by"
/// When a mob attacks an atom with an empty hand (called before COMSIG_ATOM_ATTACK_HAND)
#define COMSIG_ATOM_HAND_ATTACK "atom_hand_attack"
/// When an atom is attacked by a mob's empty hand
#define COMSIG_ATOM_ATTACK_HAND "atom_attack_hand"
/// MouseDrop
#define COMSIG_ATOM_MOUSE_DROP "atom_mouse_drop"

// atom/movable signals
/// when an AM moves (user, previous_loc, direction)
#define COMSIG_MOVABLE_MOVED "mov_moved"
// when an AM is EMP'd
#define COMSIG_MOVABLE_EMP_ACT "mov_act"

// obj signals
/// When an object is moved by a user
#define COMSIG_OBJ_MOVE_TRIGGER "obj_move_trigger"

// item signals
/// When an item is equipped (user, slot)
#define COMSIG_ITEM_EQUIPPED "itm_equip"
/// When an item is unequipped (user)
#define COMSIG_ITEM_UNEQUIPPED "itm_unequip"
/// When an item is picked up (user)
#define COMSIG_ITEM_PICKUP "itm_pickup"
/// When an item is picked dropped (user)
#define COMSIG_ITEM_DROPPED "itm_drop"
/// When an item is used to attack a mob
#define COMSIG_ITEM_ATTACK_POST "itm_atk_post"
/// When a mob attacks a target with an item
#define COMSIG_ITEM_AFTER_ATTACK "itm_after_attack"
/// When a mob uses an item in its active hand
#define COMSIG_ITEM_ATTACK_SELF "itm_atk_self"
/// For building tooltips
#define COMSIG_ITEM_BUILD_TOOLTIP "item_build_tooltip"

// blocking signals
/// After  an item block is set up
#define COMSIG_ITEM_BLOCK_BEGIN "itm_block_begin"
/// When an item block is disposed
#define COMSIG_ITEM_BLOCK_END "itm_block_end"
/// After an unarmed block is set up
#define COMSIG_UNARMED_BLOCK_BEGIN "unarmed_block_begin"
/// When an item block is created
#define COMSIG_UNARMED_BLOCK_END "unarmed_block_end"
// human signals
///when a human Life tick occurs
#define COMSIG_HUMAN_LIFE_TICK "human_life_tick"

// mob signals
///At the beginning of when an attackresults datum is being set up
#define COMSIG_MOB_ATTACKED_PRE "attacked_pre"

// storage signal
/// Get contents of a storage component
#define COMSIG_STORAGE_GET_CONTENTS "storage_get_contents"
/// Get all contents of a storage component
#define COMSIG_STORAGE_GET_ALL_CONTENTS "storage_get_all_contents"
/// Find an item type in the storage component
#define COMSIG_STORAGE_FIND_TYPE "storage_find_item"
/// Transfer an item from storage component to target
#define COMSIG_STORAGE_TRANSFER_ITEM "storage_transfer_item"
/// See if an item can fit in the storage component
#define COMSIG_STORAGE_CAN_FIT "storage_can_fit"
