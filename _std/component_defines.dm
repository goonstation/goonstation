/// Used to trigger signals and call procs registered for that signal
/// The datum hosting the signal is automaticaly added as the first argument
/// Returns a bitfield gathered from all registered procs
/// Arguments given here are packaged in a list and given to _SendSignal
#define SEND_SIGNAL(target, sigtype, arguments...) ( !target.comp_lookup || !target.comp_lookup[sigtype] ? 0 : target._SendSignal(sigtype, list(target, ##arguments)) )

/// `target` to use for signals that are global and not tied to a single datum.
/// Note that this does NOT work with SEND_SIGNAL because of preprocessor weirdness.
/// Use SEND_GLOBAL_SIGNAL instead.
#define GLOBAL_SIGNAL preMapLoad // guaranteed to exist and that's all that matters
#define SEND_GLOBAL_SIGNAL(sigtype, arguments...) ( !preMapLoad.comp_lookup || !preMapLoad.comp_lookup[sigtype] ? 0 : preMapLoad._SendSignal(sigtype, list(preMapLoad, ##arguments)) )


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


// global signals
#define COMSIG_GLOBAL_REBOOT "global_reboot"

// /datum signals
/// when a component is added to a datum: (/datum/component)
#define COMSIG_COMPONENT_ADDED "component_added"
/// before a component is removed from a datum because of RemoveComponent: (/datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"
/// just before a datum's disposing()
#define COMSIG_PARENT_PRE_DISPOSING "parent_pre_disposing"


// atom/movable signals
/// when an AM moves (user, previous_loc, direction)
#define COMSIG_MOVABLE_MOVED "mov_moved"


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
//When a mob dies
#define COMSIG_MOB_DEATH "mob_death"


// projectile signals
/// After a projectile makes a valid hit on an atom (after immunity/other early returns, before other effects)
#define COMSIG_PROJ_COLLIDE "proj_collide_atom"

// obj/critter signals
// When an obj/critter dies
#define COMSIG_OBJ_CRITTER_DEATH "obj_critter_death"
