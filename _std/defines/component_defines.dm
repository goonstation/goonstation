/// Used to trigger signals and call procs registered for that signal
/// The datum hosting the signal is automaticaly added as the first argument
/// Returns a bitfield gathered from all registered procs
/// Arguments given here are packaged in a list and given to _SendSignal
#define SEND_SIGNAL(target, sigtype, arguments...) ( !target.comp_lookup || !target.comp_lookup[sigtype] ? 0 : target._SendSignal(sigtype, list(target, ##arguments)) )

#define GLOBAL_SIGNAL preMapLoad // guaranteed to exist and that's all that matters

/**
	* `target` to use for signals that are global and not tied to a single datum.
	*
	* Note that this does NOT work with SEND_SIGNAL because of preprocessor weirdness.
	* Use SEND_GLOBAL_SIGNAL instead.
	*/
#define SEND_GLOBAL_SIGNAL(sigtype, arguments...) ( !preMapLoad.comp_lookup || !preMapLoad.comp_lookup[sigtype] ? 0 : preMapLoad._SendSignal(sigtype, list(preMapLoad, ##arguments)) )

/// A wrapper for _AddComponent that allows us to pretend we're using normal named arguments
#define AddComponent(arguments...) _AddComponent(list(##arguments))

/**
	* Return this from `/datum/component/Initialize` or `datum/component/OnTransfer` to have the component be deleted if it's applied to an incorrect type.
	*
	* `parent` must not be modified if this is to be returned.
	* This will be noted in the runtime logs.
	*/

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


// ---- global signals ----
#define COMSIG_GLOBAL_REBOOT "global_reboot"

//  ---- datum signals ----

/// when a component is added to a datum: (/datum/component)
#define COMSIG_COMPONENT_ADDED "component_added"
/// before a component is removed from a datum because of RemoveComponent: (/datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"
/// just before a datum's disposing()
#define COMSIG_PARENT_PRE_DISPOSING "parent_pre_disposing"

// ---- atom signals ----

/// when an atom changes dir (olddir, newdir)
#define COMSIG_ATOM_DIR_CHANGED "atom_dir_changed"
/// when an atom is collided by a projectile (/obj/projectile)
#define COMSIG_ATOM_HITBY_PROJ "atom_hitby_proj"

// ---- atom/movable signals ----

/// when an AM moves (user, previous_loc, direction)
#define COMSIG_MOVABLE_MOVED "mov_moved"

// ---- item signals ----

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
/// Just before an item is eaten
#define COMSIG_ITEM_CONSUMED_PRE "itm_atk_consumed_pre"
/// When an item is eaten
#define COMSIG_ITEM_CONSUMED "itm_atk_consumed"
/// When an item is used to attack a mob before it actually hurts the mob
#define COMSIG_ITEM_ATTACK_PRE "itm_atk_pre"
/// When an item is used in-hand
#define COMSIG_ITEM_ATTACK_SELF "itm_atk_self"

// ---- implant signals ----
/// When implanted
#define COMSIG_IMPLANT_IMPLANTED "implant_implanted"
/// When removed
#define COMSIG_IMPLANT_REMOVED "implant_removed"

// ---- tooltip signals ----

/// Append to the end of the blocking section of tooltip (list/tooltip)
#define COMSIG_TOOLTIP_BLOCKING_APPEND "tooltip_block_append"

// ---- blocking signals ----

/// After  an item block is set up
#define COMSIG_ITEM_BLOCK_BEGIN "itm_block_begin"
/// When an item block is disposed
#define COMSIG_ITEM_BLOCK_END "itm_block_end"
/// After an unarmed block is set up
#define COMSIG_UNARMED_BLOCK_BEGIN "unarmed_block_begin"
/// When an item block is created
#define COMSIG_UNARMED_BLOCK_END "unarmed_block_end"

// ---- human signals ----

// ---- mob signals ----

/// At the beginning of when an attackresults datum is being set up
#define COMSIG_MOB_ATTACKED_PRE "attacked_pre"
/// When a mob dies
#define COMSIG_MOB_DEATH "mob_death"

#define COMSIG_MOB_PICKUP "mob_pickup"

#define COMSIG_MOB_DROPPED "mob_drop"

#define COMSIG_MOB_CLICK "mob_click"
/// sent when radiation status ticks on mob (stage)
#define COMSIG_MOB_GEIGER_TICK "mob_geiger"
// ---- mob/living signals ----
/// when start sprinting
#define COMSIG_LIVING_SPRINT_START "living_sprint_start"
/// When a Life tick occurs
#define COMSIG_LIVING_LIFE_TICK "human_life_tick"

// ---- attack_X signals ----

/// Attacking wiht an item in-hand
#define COMSIG_ATTACKBY "attackby"


// ---- projectile signals ----

/// After a projectile makes a valid hit on an atom (after immunity/other early returns, before other effects)
#define COMSIG_PROJ_COLLIDE "proj_collide_atom"

// ---- MechComp signals - Content signals - Use these in you MechComp compatible devices ----

/// Add an input chanel for a device to send into
#define COMSIG_MECHCOMP_ADD_INPUT "mechcomp_add_input"
/// Connect two mechcomp devices together
#define COMSIG_MECHCOMP_ADD_CONFIG "mechcomp_add_config"
/// Connect two mechcomp devices together
#define COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL "mechcomp_allow_manual_sigset"
/// Remove all connected devices
#define COMSIG_MECHCOMP_RM_ALL_CONNECTIONS "mechcomp_remove_all_connections"
/// Passing the signal of a message to all connected mechcomp devices for handling (message will be instatiated by the component)
#define COMSIG_MECHCOMP_TRANSMIT_SIGNAL "mechcomp_transmit_signal"
/// Passing a message to all connected mechcomp devices for handling
#define COMSIG_MECHCOMP_TRANSMIT_MSG "mechcomp_transmit_message"
/// Passing the stored message to all connected mechcomp devices for handling
#define COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG "mechcomp_transmit_default_message"

// ---- MechComp signals - Internal signals - Do not use these ----

/// Receiving a message from a mechcomp device for handling
#define _COMSIG_MECHCOMP_RECEIVE_MSG "_mechcomp_receive_message"
/// Remove {the caller} from the list of transmitting devices
#define _COMSIG_MECHCOMP_RM_INCOMING "_mechcomp_remove_incoming"
/// Remove {the caller} from the list of receiving devices
#define _COMSIG_MECHCOMP_RM_OUTGOING "_mechcomp_remove_outgoing"
/// Return the component's outgoing connections
#define _COMSIG_MECHCOMP_GET_OUTGOING "_mechcomp_get_outgoing_connections"
/// Return the component's incoming connections
#define _COMSIG_MECHCOMP_GET_INCOMING "_mechcomp_get_incoming_connections"
/// Begin to connect two mechcomp devices together
#define _COMSIG_MECHCOMP_DROPCONNECT "_mechcomp_drop_connect"
/// Connect one MechComp compatible device as a receiver to a trigger. (This is meant to be a private method)
#define _COMSIG_MECHCOMP_LINK "_mechcomp_link_devices"
/// Returns 1
#define _COMSIG_MECHCOMP_COMPATIBLE "_mechcomp_check_compatibility"

// ---- MechComp Dispatch signals - Niche signals - You probably don't want to use these. ----
/// Add a filtered connection, getting user input on the filter
#define _COMSIG_MECHCOMP_DISPATCH_ADD_FILTER "_mechcomp_dispatch_add_filter"
/// Remove a filtered connection
#define _COMSIG_MECHCOMP_DISPATCH_RM_OUTGOING "_mechcomp_dispatch_remove_filter"
/// Test a signal to be sent to a connection
#define _COMSIG_MECHCOMP_DISPATCH_VALIDATE "_mechcomp_dispatch_run_filter"


// ---- obj/critter signals ----

// When an obj/critter dies
#define COMSIG_OBJ_CRITTER_DEATH "obj_critter_death"

/// general return values //
// it is a mystery

/// ---- signal specific return values ----

// COMSIG_LIVING_SPRINT_START
#define RETURN_SPRINT_OVERRIDDEN 0x001000
// COMSIG_MOB_CLICK
#define RETURN_CANCEL_CLICK 0x001000
